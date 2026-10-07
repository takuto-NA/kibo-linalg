#include <kibo/detail/row_kernels.hpp>
extern "C" __declspec(noinline) double probe_column_dot(const double* a,const double* b,std::size_t n){
    return kibo::linalg::detail::contiguous_dot(a,b,n,0.0);
}
