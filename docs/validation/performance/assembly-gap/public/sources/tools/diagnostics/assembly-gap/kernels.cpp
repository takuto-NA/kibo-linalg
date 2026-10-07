#include <kibo/llt.hpp>
#include <Eigen/Core>
// Match the inner reduction used by the public unblocked LLT, with dynamic count.
extern "C" __declspec(noinline) double scalar_subtract(const double* a,const double* b,std::size_t n,double value) {
    for(std::size_t k=0;k<n;++k)value-=a[k]*b[k];
    return value;
}
extern "C" __declspec(noinline) double packet_subtract(const double* a,const double* b,std::size_t n,double value) {
    return value-kibo::linalg::detail::contiguous_dot(a,b,n,0);
}
extern "C" __declspec(noinline) double eigen_subtract(const double* a,const double* b,std::size_t n,double value) {
    return value-Eigen::Map<const Eigen::VectorXd,Eigen::Unaligned>(a,n).dot(Eigen::Map<const Eigen::VectorXd,Eigen::Unaligned>(b,n));
}

extern "C" __declspec(noinline) double packet4_subtract(const double* a,const double* b,std::size_t n,double value) {
    auto s0=_mm_setzero_pd(),s1=s0,s2=s0,s3=s0;std::size_t i=0;
    for(;n-i>=8;i+=8){
        s0=_mm_add_pd(s0,_mm_mul_pd(_mm_loadu_pd(a+i),_mm_loadu_pd(b+i)));
        s1=_mm_add_pd(s1,_mm_mul_pd(_mm_loadu_pd(a+i+2),_mm_loadu_pd(b+i+2)));
        s2=_mm_add_pd(s2,_mm_mul_pd(_mm_loadu_pd(a+i+4),_mm_loadu_pd(b+i+4)));
        s3=_mm_add_pd(s3,_mm_mul_pd(_mm_loadu_pd(a+i+6),_mm_loadu_pd(b+i+6)));
    }
    auto total=_mm_add_pd(_mm_add_pd(s0,s1),_mm_add_pd(s2,s3));
    double dot=_mm_cvtsd_f64(total)+_mm_cvtsd_f64(_mm_unpackhi_pd(total,total));
    for(;i<n;++i)dot+=a[i]*b[i];return value-dot;
}
extern "C" __declspec(noinline) double scan_two_pass(const double* a,const double*,std::size_t n,double) {
    for(std::size_t i=0;i<n;++i)if(!std::isfinite(a[i]))return -1;
    double scale=0;for(std::size_t i=0;i<n;++i)if(std::abs(a[i])>scale)scale=std::abs(a[i]);return scale;
}
extern "C" __declspec(noinline) double scan_fused(const double* a,const double*,std::size_t n,double) {
    double scale=0;return kibo::linalg::detail::finite_max_abs(a,n,scale)?scale:-1;
}
