#include <kibo/qr.hpp>
#include <kibo/qr_refined.hpp>
#include <kibo/llt.hpp>
#include "controlled_fixture.hpp"
#include "fixtures/oracles.hpp"
#include <Eigen/QR>
#include <Eigen/Cholesky>
#include <Eigen/SVD>
#include <iomanip>
#include <iostream>
#include <string_view>

using namespace kibo::linalg;
using kibo::tests::RowMatrix;
bool column_factor=false;
#define CHECK(condition) do { if (!(condition)) { std::cerr<<"line "<<__LINE__<<": "<<#condition<<'\n'; ++failures; } } while(false)
MatrixView<const double> view(const RowMatrix& matrix) {
    return MatrixView<const double>::checked({matrix.data(),static_cast<std::size_t>(matrix.size())},
        matrix.rows(),matrix.cols(),matrix.cols()).value();
}
MatrixView<double> view(RowMatrix& matrix) {
    return MatrixView<double>::checked({matrix.data(),static_cast<std::size_t>(matrix.size())},
        matrix.rows(),matrix.cols(),matrix.cols()).value();
}
MatrixView<double> factor_view(RowMatrix& matrix) {
    if (!column_factor) return view(matrix);
    return MatrixView<double>::checked({matrix.data(),static_cast<std::size_t>(matrix.size())},
        matrix.rows(),matrix.cols(),1,matrix.rows()).value();
}
int main(int argc,char** argv) {
    int failures=0;
    int eigen_accuracy_failures=0;
    std::cerr<<std::setprecision(17);
    // The reference solver's accuracy is diagnostic; kibo's CHECKs remain gates.
    auto record_eigen_accuracy=[&](double error,double threshold) {
        const bool passed=error<=threshold;
        std::cerr<<" eigen_forward_error="<<error<<" threshold="<<threshold<<" passed="<<passed<<'\n';
        if(!passed) ++eigen_accuracy_failures;
    };
    Eigen::Index maximum_n=512;
    for (int i=1;i<argc;++i) {
        if (std::string_view{argv[i]}=="--small") maximum_n=32;
        if (std::string_view{argv[i]}=="--column-factor") column_factor=true;
    }
    for(const auto& oracle:kibo::tests::rank_oracles) {
        RowMatrix a=Eigen::Map<const RowMatrix>(oracle.matrix,oracle.m,oracle.n),packed(oracle.m,oracle.n);
        std::vector<double> tau(oracle.n),work(oracle.m+oracle.n);
        std::vector<std::size_t> permutation(oracle.n);
        QrDiagnostics diagnostics;
        auto factor=factorize_qr(view(a),factor_view(packed),tau,permutation,std::as_writable_bytes(std::span<double>{work}),
            QrOptions{oracle.tolerance},&diagnostics);
        CHECK(diagnostics.rank==oracle.rank);
        CHECK(oracle.rank==oracle.n ? static_cast<bool>(factor) : !factor && factor.status().code==StatusCode::rank_deficient);
        auto eigen=a.colPivHouseholderQr(); eigen.setThreshold(oracle.tolerance);
        CHECK(eigen.rank()==static_cast<Eigen::Index>(oracle.rank));
    }
    std::cout<<"m,n,condition,inconsistent,qr_forward,optimality,normal_llt_forward,normal_llt_status,qr_fast_forward,qr_fast_optimality\n"<<std::setprecision(17);
    for (const auto& oracle:kibo::tests::oracles) {
        RowMatrix a=Eigen::Map<const RowMatrix>(oracle.matrix,oracle.m,oracle.n);
        Eigen::VectorXd b=Eigen::Map<const Eigen::VectorXd>(oracle.rhs,oracle.m);
        Eigen::VectorXd expected=Eigen::Map<const Eigen::VectorXd>(oracle.solution,oracle.n);
        RowMatrix packed(oracle.m,oracle.n);
        std::vector<double> tau(oracle.n),result(oracle.n),work(2*oracle.m+3*oracle.n);
        std::vector<std::size_t> permutation(oracle.n);
        auto workspace=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(view(a),factor_view(packed),tau,permutation,workspace);
        const bool solved=factor && solve_into(factor.value(),{b.data(),oracle.m},result,workspace);
        CHECK(solved);
        if(!solved) continue;
        Eigen::Map<const Eigen::VectorXd> x(result.data(),oracle.n);
        const double fast_error=(x-expected).norm()/expected.norm();
        const auto refined=solve_refined_into(factor.value(),view(a),{b.data(),oracle.m},result,workspace);
        CHECK(refined);
        if(!refined) continue;
        if (!((x-expected).norm()/expected.norm()<=1e-4)) {
            std::cerr<<"oracle n="<<oracle.n<<" amax="<<a.cwiseAbs().maxCoeff()<<"\nexpected "<<expected.transpose()
                <<"\nQR "<<x.transpose()<<"\nEigen "<<a.colPivHouseholderQr().solve(b).transpose()<<'\n';
        }
        CHECK((x-expected).norm()/expected.norm()<=1e-4);
        // Eigen is measured on both the original and normalized input.
        auto raw_eigen=a.colPivHouseholderQr();
        Eigen::VectorXd raw_reference=raw_eigen.solve(b);
        const double core_error=(x-expected).norm()/expected.norm();
        const double raw_error=(raw_reference-expected).norm()/expected.norm();
        std::cerr<<"oracle n="<<oracle.n<<" scale="<<a.cwiseAbs().maxCoeff()<<" core_error="<<core_error<<" core_fast_error="<<fast_error
                 <<" Eigen_raw_error="<<raw_error<<'\n';
        const double normalization=a.cwiseAbs().maxCoeff();
        RowMatrix normalized=a/normalization;
        auto eigen=normalized.colPivHouseholderQr(); eigen.setThreshold(oracle.m*std::numeric_limits<double>::epsilon());
        CHECK(eigen.rank()==static_cast<Eigen::Index>(oracle.n));
        const Eigen::VectorXd normalized_b=b/normalization;
        Eigen::VectorXd reference=eigen.solve(normalized_b);
        std::cerr<<"Eigen oracle m="<<oracle.m<<" n="<<oracle.n<<" scale="<<normalization
                 <<" column_factor="<<column_factor;
        record_eigen_accuracy((reference-expected).norm()/expected.norm(),1e-4);
    }
    for (const Eigen::Index n:{2,8,32,128,512}) for (const Eigen::Index m:{n,4*n}) {
        if(n>maximum_n) continue;
        for (const double condition:{2.0,1e4,1e8}) for (const bool inconsistent:{false,true}) {
            if (m==n && inconsistent) continue; // full-rank square systems have no orthogonal residual
            auto fixture=kibo::tests::controlled_fixture(m,n,condition,inconsistent);
            const auto& a=fixture.matrix;
            if(!inconsistent) {
                Eigen::JacobiSVD<RowMatrix> spectrum(a);
                const auto& singular=spectrum.singularValues();
                CHECK(singular[n-1]>0);
                CHECK(std::abs((singular[0]/singular[n-1])/condition-1)<=0.01);
            }
            RowMatrix packed(m,n);
            std::vector<double> tau(n),result(n),work(2*m+3*n);
            std::vector<std::size_t> permutation(n);
            auto workspace=std::as_writable_bytes(std::span<double>{work});
            auto factor=factorize_qr(view(a),factor_view(packed),tau,permutation,workspace);
            const bool solved=factor && solve_into(factor.value(),{fixture.rhs.data(),static_cast<std::size_t>(m)},result,workspace);
            CHECK(solved);
            if(!solved) continue;
            Eigen::Map<const Eigen::VectorXd> x(result.data(),n);
            const double fast_forward=(x-fixture.truth).norm()/fixture.truth.norm();
            const Eigen::VectorXd fast_residual=a*x-fixture.rhs;
            const double fast_optimality=(a.transpose()*fast_residual).norm()/(a.norm()*(a.norm()*x.norm()+fixture.rhs.norm()));
            if(condition<=1e4) CHECK(fast_forward<=1e-8);
            CHECK(fast_optimality<=100*std::numeric_limits<double>::epsilon()*static_cast<double>(m));
            const auto refined=solve_refined_into(factor.value(),view(a),{fixture.rhs.data(),static_cast<std::size_t>(m)},result,workspace);
            CHECK(refined);
            if(!refined) continue;
            const double forward=(x-fixture.truth).norm()/fixture.truth.norm();
            const Eigen::VectorXd residual=a*x-fixture.rhs;
            const double backward=residual.norm()/(a.norm()*x.norm()+fixture.rhs.norm());
            const double optimality=(a.transpose()*residual).norm()/(a.norm()*(a.norm()*x.norm()+fixture.rhs.norm()));
            CHECK(forward<=(condition<=1e4 ? 1e-8 : 1e-4));
            CHECK(optimality<=100*std::numeric_limits<double>::epsilon()*static_cast<double>(m));
            if(!inconsistent) CHECK(backward<=100*std::numeric_limits<double>::epsilon()*static_cast<double>(m));
            auto eigen=a.colPivHouseholderQr(); eigen.setThreshold(static_cast<double>(m)*std::numeric_limits<double>::epsilon());
            CHECK(eigen.rank()==n);
            Eigen::VectorXd reference=eigen.solve(fixture.rhs);
            std::cerr<<"Eigen fixture m="<<m<<" n="<<n<<" condition="<<condition
                     <<" inconsistent="<<inconsistent<<" column_factor="<<column_factor;
            record_eigen_accuracy((reference-fixture.truth).norm()/fixture.truth.norm(),condition<=1e4 ? 1e-8 : 1e-4);
            RowMatrix normal=a.transpose()*a,lower(n,n);
            Eigen::VectorXd rhs=a.transpose()*fixture.rhs;
            auto llt=factorize_llt(view(normal),view(lower));
            Status status=llt ? solve_into(llt.value(),{rhs.data(),static_cast<std::size_t>(n)},result,workspace) : llt.status();
            const double llt_error=status ? (Eigen::Map<const Eigen::VectorXd>(result.data(),n)-fixture.truth).norm()/fixture.truth.norm() : std::numeric_limits<double>::quiet_NaN();
            std::cout<<m<<','<<n<<','<<condition<<','<<inconsistent<<','<<forward<<','<<optimality<<','<<llt_error<<','<<static_cast<int>(status.code)<<','<<fast_forward<<','<<fast_optimality<<'\n';
            if(condition<=1e4) CHECK(status && llt_error<=1e-8);
        }
        auto deficient=kibo::tests::controlled_fixture(m,n,2,false,true);
        RowMatrix storage(m,n);
        std::vector<double> tau(n),work(m+n);
        std::vector<std::size_t> permutation(n);
        QrDiagnostics diagnostics;
        auto failed=factorize_qr(view(deficient.matrix),factor_view(storage),tau,permutation,std::as_writable_bytes(std::span<double>{work}),{},&diagnostics);
        CHECK(!failed && failed.status().code==StatusCode::rank_deficient && diagnostics.rank==static_cast<std::size_t>(n-1));
    }
    std::cerr<<"numerical acceptance failures="<<failures<<'\n';
    std::cerr<<"Eigen accuracy diagnostic failures="<<eigen_accuracy_failures<<'\n';
    return failures ? 1 : 0;
}
