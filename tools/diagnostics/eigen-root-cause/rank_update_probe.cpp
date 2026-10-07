// Isolated triangular C -= U*U^T diagnostic; never an installed kernel.
#include <kibo/detail/row_kernels.hpp>
#include <Eigen/Dense>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <vector>
#include "affinity.hpp"

using RowMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor>;
using ColumnMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::ColMajor>;
using Clock=std::chrono::steady_clock;
volatile double consumed_rank_update;

template<class Matrix,class Update>
bool measure(const char* method,Matrix& output,const Matrix& initial,
             const ColumnMatrix& product,std::size_t width,Update&& update) {
    std::vector<double> samples;
    std::size_t calls=1;
    // Resetting C and checking the independent expected result are outside timing.
    // Repeated updates avoid a per-call clock/copy cost inside the measured batch.
    for(int sample=-2;sample<15;) {
        output=initial;
        const auto start=Clock::now();
        for(std::size_t call=0;call<calls;++call) update();
        consumed_rank_update=output(0,0);
        const double seconds=std::chrono::duration<double>(Clock::now()-start).count();
        double maximum_error=0;
        for(Eigen::Index i=0;i<output.rows();++i) for(Eigen::Index j=0;j<=i;++j) {
            const double expected=initial(i,j)-double(calls)*product(i,j);
            if(!std::isfinite(output(i,j))) return false;
            maximum_error=std::max(maximum_error,std::abs(output(i,j)-expected)/std::max(1.0,std::abs(expected)));
        }
        if(maximum_error>1e-10) return false;
        if(seconds<0.020) {
            if(calls>(std::size_t{1}<<23)) return false;
            calls*=2;
            continue;
        }
        if(sample>=0) samples.push_back(seconds/double(calls));
        ++sample;
    }
    std::sort(samples.begin(),samples.end());
    const auto r=std::size_t(output.rows());
    const auto q=r*(r+1)/2;
    std::printf("{\"method\":\"%s\",\"remaining\":%zu,\"rank\":%zu,\"seconds\":%.12g,"
                "\"samples\":15,\"callsPerBatch\":%zu,\"triangularOutputs\":%zu,"
                "\"multiplySubtractPairs\":%zu,\"accuracyPassed\":true}\n",
                method,r,width,samples[7],calls,q,width*q);
    return true;
}

int main() {
    if(!pin_probe())return 20;
    Eigen::setNbThreads(1);
    std::printf("[LLT-rank-update] packet=%d coreSIMD=%d mr=%d nr=%d\n",
        Eigen::internal::packet_traits<double>::size,kibo::linalg::detail::row_simd_available,
        Eigen::internal::gebp_traits<double,double>::mr,Eigen::internal::gebp_traits<double,double>::nr);
    // Equal remaining size/rank/layout pairs. 504x8 and 448x64 are the first
    // public n=512 trailing panels; other cases distinguish crossover effects.
    for(const auto remaining:{64,128,256,448,504}) for(const auto width:{8,64}) {
        ColumnMatrix u(remaining,width),column_initial(remaining,remaining);
        RowMatrix coefficients(remaining,width),row_initial(remaining,remaining);
        for(int i=0;i<remaining;++i) {
            for(int k=0;k<width;++k) {
                const double value=(double((i*13+k*7)%17)-8)*0.03125;
                u(i,k)=value;coefficients(i,k)=value;
            }
            for(int j=0;j<remaining;++j)
                column_initial(i,j)=row_initial(i,j)=1+double((i*3+j*5)%7)*0.125;
        }
        // All oracle products are dyadic and small. Oracle construction and
        // the row kernel's already mirrored coefficient layout are not timed.
        const ColumnMatrix product=u*u.transpose();
        ColumnMatrix column_core=column_initial,column_eigen=column_initial;
        RowMatrix row_core=row_initial,row_eigen=row_initial;
        std::vector<double> column_coefficients(width);
        const auto core_row=[&] {
            for(int i=0;i<remaining;++i)
                kibo::linalg::detail::row_update_panel(&row_core(i,0),u.data(),u.outerStride(),
                    &coefficients(i,0),width,std::size_t(i+1));
        };
        const auto core_column=[&] {
            for(int j=0;j<remaining;++j) {
                for(int k=0;k<width;++k) column_coefficients[k]=u(j,k);
                kibo::linalg::detail::row_update_panel(&column_core(j,j),&u(j,0),u.outerStride(),
                    column_coefficients.data(),width,std::size_t(remaining-j));
            }
        };
        const auto eigen_row=[&] {row_eigen.selfadjointView<Eigen::Lower>().rankUpdate(u,-1.0);};
        const auto eigen_column=[&] {column_eigen.selfadjointView<Eigen::Lower>().rankUpdate(u,-1.0);};
        // Rotate method order by shape. Run full-method batches serially;
        // within-process ratios are descriptive, not a formal paired CI.
        bool passed=true;
        if((remaining+width)%3==0) {
            passed=measure("eigen-row",row_eigen,row_initial,product,width,eigen_row)&&
                   measure("core-row",row_core,row_initial,product,width,core_row)&&
                   measure("eigen-column",column_eigen,column_initial,product,width,eigen_column)&&
                   measure("core-column",column_core,column_initial,product,width,core_column);
        } else {
            passed=measure("core-row",row_core,row_initial,product,width,core_row)&&
                   measure("eigen-row",row_eigen,row_initial,product,width,eigen_row)&&
                   measure("core-column",column_core,column_initial,product,width,core_column)&&
                   measure("eigen-column",column_eigen,column_initial,product,width,eigen_column);
        }
        if(!passed) return 2;
    }
    return 0;
}
