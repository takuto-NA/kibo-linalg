// Standalone causal probe, not a public-contract or formal performance gate.
// Build with this scratch include/, pinned Eigen, C++20, /O2 /fp:precise,
// EIGEN_DONT_PARALLELIZE=1; no KIBO_DIAG_* or KIBO_QR_ABLATION_* overrides.
#include <kibo/detail/row_kernels.hpp>
#include <Eigen/Core>
#include "affinity.hpp"
#include <algorithm>
#include <array>
#include <bit>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <limits>
#include <vector>

namespace {
using Clock=std::chrono::steady_clock;
using RowMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor>;
using ColMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::ColMajor>;
constexpr std::array names{"row_single","row_four","column_single","column_four","eigen_row","eigen_column"};
volatile double consumed=0;
struct Data {
    std::size_t m,n;
    RowMatrix row;
    ColMatrix column;
    Eigen::VectorXd v;
    // The existing four-row signature expects coefficients[i*matrix_stride].
    // Both row variants use this identical coefficient representation.
    std::vector<double> row_coefficients,oracle,q;
    Data(std::size_t rows,std::size_t columns):m(rows),n(columns),row(rows,columns),
        column(rows,columns),v(rows),row_coefficients(rows*columns),oracle(columns),q(columns) {
        std::vector<std::int64_t> integer_sums(n);
        for(std::size_t i=0;i<m;++i) {
            const int vi=static_cast<int>((i*7+3)%9)-4;
            v[i]=static_cast<double>(vi)/8;
            row_coefficients[i*n]=v[i];
            for(std::size_t j=0;j<n;++j) {
                const int a=static_cast<int>((i*13+j*11+(i*j)%19)%17)-8;
                row(i,j)=static_cast<double>(a)/16;
                integer_sums[j]+=static_cast<std::int64_t>(a)*vi;
            }
        }
        column=row; // Native-layout copy excluded from all timings.
        for(std::size_t j=0;j<n;++j)oracle[j]=static_cast<double>(integer_sums[j])/128;
        // Every intermediate product/sum is exactly representable (integer/128,
        // at most 2560*32 numerator magnitude); reduction order cannot alter it.
    }
    bool exact() const {
        for(std::size_t j=0;j<n;++j)if(q[j]!=oracle[j])return false;
        return true;
    }
    std::uint64_t hash() const {
        std::uint64_t h=14695981039346656037ULL;
        auto append=[&](std::uint64_t value){for(int b=0;b<8;++b){h^=(value>>(8*b))&255;h*=1099511628211ULL;}};
        append(m);append(n);
        for(Eigen::Index i=0;i<row.size();++i)append(std::bit_cast<std::uint64_t>(row.data()[i]));
        for(Eigen::Index i=0;i<v.size();++i)append(std::bit_cast<std::uint64_t>(v[i]));
        return h;
    }
};

// Prevent the optimizer from collapsing repeated identical calls in a batch.
#if defined(_MSC_VER)
__declspec(noinline)
#elif defined(__GNUC__) || defined(__clang__)
__attribute__((noinline))
#endif
void project(Data& d,std::size_t method) {
    using namespace kibo::linalg::detail;
    if(method==0) {
        std::fill(d.q.begin(),d.q.end(),0);
        for(std::size_t i=0;i<d.m;++i)row_project(d.q.data(),d.row.data()+i*d.n,d.n,d.row_coefficients[i*d.n]);
    } else if(method==1) {
        std::fill(d.q.begin(),d.q.end(),0);
        std::size_t i=0;
        for(;d.m-i>=4;i+=4)row_project_four_rows(d.q.data(),d.row.data()+i*d.n,d.n,d.row_coefficients.data()+i*d.n,d.n);
        for(;i<d.m;++i)row_project(d.q.data(),d.row.data()+i*d.n,d.n,d.row_coefficients[i*d.n]);
    } else if(method==2) {
        // Match column_four's output initialization cost for this causal pair.
        std::fill(d.q.begin(),d.q.end(),0);
        for(std::size_t j=0;j<d.n;++j)d.q[j]=contiguous_dot(d.v.data(),d.column.data()+j*d.m,d.m,0);
    } else if(method==3) {
        std::fill(d.q.begin(),d.q.end(),0);
        std::size_t j=0;
        for(;d.n-j>=4;j+=4)column_project_four(d.q.data()+j,d.column.data()+j*d.m,d.m,d.v.data(),d.m);
        for(;j<d.n;++j)d.q[j]=contiguous_dot(d.v.data(),d.column.data()+j*d.m,d.m,0);
    } else {
        Eigen::Map<Eigen::VectorXd> output(d.q.data(),d.n);
        if(method==4)output.noalias()=d.row.transpose()*d.v;
        else output.noalias()=d.column.transpose()*d.v;
    }
    consumed=d.q[0];
}
double timed(Data& data,std::size_t method,std::size_t batch) {
    const auto begin=Clock::now();
    for(std::size_t i=0;i<batch;++i)project(data,method);
    return std::chrono::duration<double>(Clock::now()-begin).count();
}
}

int main(int argc,char** argv) {
    if(!pin_probe())return 20;
    const int process=argc>1?std::atoi(argv[1]):0;
    if(process<0)return 10;
    Eigen::setNbThreads(1);
    constexpr int samples=15;
    constexpr double minimum=.020,calibration=.025;
    std::printf("{\"kind\":\"protocol\",\"operation\":\"q=A^T*v\",\"process\":%d,\"samples\":15,\"warmups\":2,\"minimumBatchSeconds\":0.02,\"logicalCpu\":0,\"cpuidCoreType\":%u,\"coreSIMD\":%d,\"eigenPacketWidth\":%d,\"rowCoefficientLayout\":\"stride=n for both row helpers\",\"timedWork\":\"projection plus output initialization/overwrite; excludes native-layout copies, oracle and validation\",\"sameLayoutPairs\":[[\"row_single\",\"row_four\"],[\"column_single\",\"column_four\"]],\"layoutChangingPairs\":[[\"row_single\",\"column_single\"],[\"eigen_row\",\"eigen_column\"]],\"contractCertification\":false}\n",process,probe_core_type(),kibo::linalg::detail::row_simd_available,Eigen::internal::packet_traits<double>::size);
    for(const std::size_t m: {std::size_t{1024},std::size_t{2560}}) {
        Data data(m,512);
        const auto input_hash=data.hash();
        std::array<std::size_t,6> batches{};
        std::array<std::vector<double>,6> results;
        for(std::size_t method=0;method<names.size();++method) {
            for(int warmup=0;warmup<2;++warmup){project(data,method);if(!data.exact())return 11;}
            batches[method]=1;
            while(timed(data,method,batches[method])<calibration) {
                if(batches[method]>std::numeric_limits<std::size_t>::max()/2)return 12;
                batches[method]*=2;
            }
            if(!data.exact())return 13;
        }
        for(int sample=0;sample<samples;++sample) {
            // Rotate starting method and reverse alternate sweeps across processes.
            for(std::size_t order=0;order<names.size();++order) {
                const std::size_t offset=(sample+process)%names.size();
                const std::size_t method=((sample+process)%2==0?offset+order:offset+names.size()-order)%names.size();
                double seconds;
                for(;;) {
                    seconds=timed(data,method,batches[method]);
                    if(!data.exact())return 14;
                    if(seconds>=minimum)break;
                    if(batches[method]>std::numeric_limits<std::size_t>::max()/2)return 15;
                    batches[method]*=2;
                }
                results[method].push_back(seconds/batches[method]);
                std::printf("{\"kind\":\"sample\",\"process\":%d,\"sample\":%d,\"method\":\"%s\",\"rows\":%zu,\"columns\":512,\"batch\":%zu,\"batchSeconds\":%.17g,\"secondsPerProjection\":%.17g,\"oracleExact\":true,\"inputHash\":\"%016llx\"}\n",process,sample,names[method],m,batches[method],seconds,seconds/batches[method],static_cast<unsigned long long>(input_hash));
            }
        }
        for(std::size_t method=0;method<names.size();++method) {
            auto values=results[method];std::sort(values.begin(),values.end());
            std::printf("{\"kind\":\"summary\",\"process\":%d,\"method\":\"%s\",\"rows\":%zu,\"columns\":512,\"samples\":15,\"medianSeconds\":%.17g,\"p95Seconds\":%.17g,\"oracleExact\":true}\n",process,names[method],m,values[7],values[14]);
        }
    }
    return 0;
}
