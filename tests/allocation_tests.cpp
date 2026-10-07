#include <kibo/linalg.hpp>
#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <kibo/qr_refined.hpp>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <new>
#include <vector>
namespace {
volatile bool measuring=false;
std::size_t allocations=0;
}
#if defined(_MSC_VER) && defined(_DEBUG)
#include <crtdbg.h>
namespace {
int allocation_hook(int type, void*, std::size_t, int, long, const unsigned char*, int) {
    if (measuring && (type==_HOOK_ALLOC || type==_HOOK_REALLOC)) ++allocations;
    return 1;
}
}
#endif
#if defined(KIBO_WRAP_ALLOCATORS)
extern "C" {
void* __real_malloc(std::size_t);
void* __real_calloc(std::size_t,std::size_t);
void* __real_realloc(void*,std::size_t);
void* __real_aligned_alloc(std::size_t,std::size_t);
void* __wrap_malloc(std::size_t size) {if(measuring)++allocations; return __real_malloc(size);}
void* __wrap_calloc(std::size_t count,std::size_t size) {if(measuring)++allocations; return __real_calloc(count,size);}
void* __wrap_realloc(void* pointer,std::size_t size) {if(measuring)++allocations; return __real_realloc(pointer,size);}
void* __wrap_aligned_alloc(std::size_t alignment,std::size_t size) {if(measuring)++allocations; return __real_aligned_alloc(alignment,size);}
}
// The linker's malloc wrappers also observe these calls. Replacement new
// covers allocations from dynamically linked C++ standard-library code.
void* operator new(std::size_t size) {
    if(measuring)++allocations;
    if(void* pointer=std::malloc(size ? size : 1)) return pointer;
    std::abort();
}
void* operator new[](std::size_t size) {return ::operator new(size);}
void operator delete(void* pointer) noexcept {std::free(pointer);}
void operator delete[](void* pointer) noexcept {std::free(pointer);}
void operator delete(void* pointer,std::size_t) noexcept {std::free(pointer);}
void operator delete[](void* pointer,std::size_t) noexcept {std::free(pointer);}
void* operator new(std::size_t size,std::align_val_t alignment) {
    if(measuring)++allocations;
    const auto value=static_cast<std::size_t>(alignment);
    const auto count=size ? size : value;
    if(count>std::numeric_limits<std::size_t>::max()-(value-1)) std::abort();
    if(void* pointer=std::aligned_alloc(value,(count+value-1)/value*value)) return pointer;
    std::abort();
}
void* operator new[](std::size_t size,std::align_val_t alignment) {return ::operator new(size,alignment);}
void operator delete(void* pointer,std::align_val_t) noexcept {std::free(pointer);}
void operator delete[](void* pointer,std::align_val_t) noexcept {std::free(pointer);}
void operator delete(void* pointer,std::size_t,std::align_val_t) noexcept {std::free(pointer);}
void operator delete[](void* pointer,std::size_t,std::align_val_t) noexcept {std::free(pointer);}
#endif
namespace {
bool prepared_dense_shapes() {
    using namespace kibo::linalg;
    for(const std::size_t n:{2,8,32,128,512}) for(const std::size_t m:{n,4*n}) {
#if !defined(NDEBUG)
        if(n>32) continue; // the Release Linux probe covers the complete scale range
#endif
        std::vector<double> input(m*n),packed(m*n),rhs(m),solution(n),tau(n),work(2*m+3*n);
        std::vector<std::size_t> permutation(n);
        for(std::size_t i=0;i<n;++i) {input[i*n+i]=2;rhs[i]=1;}
        auto a=MatrixView<const double>::checked(input,m,n,n).value();
        auto factor_storage=MatrixView<double>::checked(packed,m,n,n).value();
        auto square=a.submatrix(0,0,n,n).value();
        auto lower=factor_storage.submatrix(0,0,n,n).value();
        const auto rhs_span=std::span<const double>{rhs};
        auto output_span=std::span<double>{solution};
        auto workspace=std::as_writable_bytes(std::span<double>{work});
        allocations=0; measuring=true;
        auto llt=factorize_llt(square,lower);
        const bool llt_ok=llt && solve_into(llt.value(),rhs_span.first(n),output_span,workspace);
        bool correct=llt_ok;
        if(llt_ok) for(auto value:solution) correct=std::abs(value-0.5)<=1e-14 && correct;
        auto qr=factorize_qr(a,factor_storage,tau,permutation,workspace);
        const bool qr_ok=qr && solve_into(qr.value(),rhs_span,output_span,workspace);
        correct=qr_ok && correct;
        if(qr_ok) for(auto value:solution) correct=std::abs(value-0.5)<=1e-14 && correct;
        auto column_storage=MatrixView<double>::checked(packed,m,n,1,m).value();
        auto column_qr=factorize_qr(a,column_storage,tau,permutation,workspace);
        const bool column_ok=column_qr && solve_into(column_qr.value(),rhs_span,output_span,workspace);
        correct=column_ok && correct;
        if(column_ok) for(auto value:solution) correct=std::abs(value-0.5)<=1e-14 && correct;
        const bool refined_ok=column_qr && solve_refined_into(column_qr.value(),a,rhs_span,output_span,workspace);
        correct=refined_ok && correct;
        if(refined_ok) for(auto value:solution) correct=std::abs(value-0.5)<=1e-14 && correct;
        measuring=false;
        std::printf("prepared m=%zu n=%zu LLT/QR allocator calls=%zu\n",m,n,allocations);
        if(!correct || allocations!=0) return false;
    }
    return true;
}
}
int main() {
#if (defined(_MSC_VER) && defined(_DEBUG)) || defined(KIBO_WRAP_ALLOCATORS)
#if defined(_MSC_VER) && defined(_DEBUG)
    const auto previous=_CrtSetAllocHook(allocation_hook);
#endif
    measuring=true;
    void* volatile calibration=std::malloc(16);
    measuring=false;
    std::free(calibration);
    if (allocations==0) { std::fputs("allocation probe failed calibration\n",stderr); return 1; }
    kibo::linalg::StaticMatrix<double,2,2> a, output, factor_storage;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> product{};
    alignas(double) std::array<std::byte,16> workspace{};
    std::array<double,2> tau{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,32> qr_workspace{};
    bool ok=true;
    allocations=0; measuring=true;
    for (int repeat=0;repeat<100;++repeat) {
        ok=static_cast<bool>(kibo::linalg::matvec_into(a.view(),std::span<const double>{b},std::span<double>{product})) && ok;
        ok=static_cast<bool>(kibo::linalg::matmul_into(a.view(),a.view(),output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::identity_into(output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::copy_into(a.view(),output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::add_into(a.view(),output.view(),output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::sub_into(output.view(),a.view(),output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::scale_into(output.view(),1.0,output.view())) && ok;
        ok=static_cast<bool>(kibo::linalg::add_diagonal_inplace(output.view(),1.0)) && ok;
        ok=static_cast<bool>(kibo::linalg::fill_into(output.view(),0.0)) && ok;
        ok=static_cast<bool>(kibo::linalg::dot(std::span<const double>{b},std::span<const double>{b})) && ok;
        ok=static_cast<bool>(kibo::linalg::stable_norm2(std::span<const double>{b})) && ok;
        auto factor=kibo::linalg::factorize_llt(a.const_view(),factor_storage.view());
        ok=static_cast<bool>(factor) && ok;
        if (factor) ok=static_cast<bool>(kibo::linalg::solve_into(factor.value(),std::span<const double>{b},std::span<double>{product},workspace)) && ok;
        auto qr=kibo::linalg::factorize_qr(a.const_view(),factor_storage.view(),tau,permutation,qr_workspace);
        ok=static_cast<bool>(qr) && ok;
        if (qr) ok=static_cast<bool>(kibo::linalg::solve_into(qr.value(),std::span<const double>{b},std::span<double>{product},qr_workspace)) && ok;
    }
    measuring=false;
    const auto small_allocations=allocations;
    ok=prepared_dense_shapes() && ok;
#if defined(_MSC_VER) && defined(_DEBUG)
    _CrtSetAllocHook(previous);
#endif
    std::printf("prepared basic operations, LLT and QR factor/solve: observed allocator calls=%zu\n",small_allocations);
    return !ok || small_allocations!=0;
#else
    std::puts("CRT allocation probe requires MSVC Debug; no measurement in this configuration");
    return 77;
#endif
}
