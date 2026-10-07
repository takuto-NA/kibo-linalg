#include <kibo/qr.hpp>
#include "controlled_fixture.hpp"
#include <Eigen/QR>
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <vector>
volatile double consumed;
int main() {
    using namespace kibo::linalg;
    std::printf("[DEBUG-eigen-cause] Eigen double packet=%d coreSIMD=%d\n",Eigen::internal::packet_traits<double>::size,detail::row_simd_available);
    Eigen::setNbThreads(1);
    const std::size_t m=1024,n=512;
    const auto fixture=kibo::tests::performance_fixture(m,n);
    auto input=MatrixView<const double>::checked(std::span<const double>{fixture.matrix.data(),m*n},m,n,n).value();
    std::vector<double> packed(m*n),tau(n),workspace(m+n),solution(n);
    std::vector<std::size_t> permutation(n);
#if defined(KIBO_DIAG_CORE_COLUMN)
    auto storage=MatrixView<double>::checked(packed,m,n,1,m).value();
#else
    auto storage=MatrixView<double>::checked(packed,m,n,n).value();
#endif
    auto work=std::as_writable_bytes(std::span<double>{workspace});
    using EMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,
#if defined(KIBO_DIAG_EIGEN_ROW)
        Eigen::RowMajor
#else
        Eigen::ColMajor
#endif
    >;
    EMatrix column=fixture.matrix;
    Eigen::ColPivHouseholderQR<EMatrix> reference(m,n);
    Eigen::VectorXd eigen_solution(n);
    std::vector<double> core_times,eigen_times;
    for(int repeat=0;repeat<4;++repeat) {
        const auto run_core=[&]{
            const auto start=std::chrono::steady_clock::now();
            auto factor=factorize_qr(input,storage,tau,permutation,work);
            if(!factor || !solve_into(factor.value(),std::span<const double>{fixture.rhs.data(),m},solution,work)) return false;
            consumed=solution[0];
            const double seconds=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
            for(auto value:solution) if(!std::isfinite(value) || std::abs(value-1)>1e-10) return false;
            if(repeat>0) core_times.push_back(seconds);
            return true;
        };
        const auto run_eigen=[&]{
            const auto start=std::chrono::steady_clock::now();
            reference.compute(column);
            eigen_solution=reference.solve(fixture.rhs);
            consumed=eigen_solution[0];
            const double seconds=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
            if(!eigen_solution.allFinite() || (eigen_solution.array()-1).abs().maxCoeff()>1e-10) return false;
            if(repeat>0) eigen_times.push_back(seconds);
            return true;
        };
        if(repeat%2==0) { if(!run_core() || !run_eigen()) return 2; }
        else if(!run_eigen() || !run_core()) return 2;
    }
    std::sort(core_times.begin(),core_times.end());
    std::sort(eigen_times.begin(),eigen_times.end());
    const double ratio=core_times[1]/eigen_times[1];
    std::printf("{\"m\":%zu,\"n\":%zu,\"coreSeconds\":%.9g,\"eigenSeconds\":%.9g,\"coreOverEigen\":%.9g,\"accuracyPassed\":true}\n",m,n,core_times[1],eigen_times[1],ratio);
    double measured_phases[6];
    std::copy(std::begin(cause::times),std::end(cause::times),measured_phases);
    // Local diagnosis target: flag a gap exceeding 1.1x. Not a CI speed gate.
    {
        const double a[2]={1,-1}; double packed_failure[2]{}; double tau_failure[1]{};
        std::size_t p_failure[1]{};double w_failure[3]{};double sentinel=-123;
        const double rhs_failure[2]={.9*std::numeric_limits<double>::max(),.9*std::numeric_limits<double>::max()};
        auto av=MatrixView<const double>::checked(a,2,1,1).value();
        auto pv=MatrixView<double>::checked(packed_failure,2,1,1).value();
        auto wf=std::as_writable_bytes(std::span<double>(w_failure));
        auto f=factorize_qr(av,pv,tau_failure,p_failure,wf);
        if(!f) return 3;
        auto status=solve_into(f.value(),rhs_failure,std::span<double>(&sentinel,1),wf);
        const bool passed=status.code==StatusCode::arithmetic_failure && sentinel==-123;
        std::printf("[DEBUG-eigen-cause] residual-overflow-output-preserved=%d\n",passed);
        if(!passed) return 3;
    }
    for(int i=0;i<6;++i) std::printf("[DEBUG-eigen-cause] phase%d=%.3f ms\n",i,measured_phases[i]*1000/4);
    return ratio>1.1 ? 1 : 0;
}
