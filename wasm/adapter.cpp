#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <kibo/qr_refined.hpp>
#include <emscripten/heap.h>
#include <array>
#include <cstdint>
#include <cstring>
#include <cstdlib>

namespace {
bool measuring=false;
std::uint32_t allocation_count=0;
struct AllocationScope {
    AllocationScope() noexcept { allocation_count=0; measuring=true; }
    ~AllocationScope() { measuring=false; }
};
}
extern "C" {
void* __real_malloc(std::size_t);
void* __real_calloc(std::size_t,std::size_t);
void* __real_realloc(void*,std::size_t);
void* __real_aligned_alloc(std::size_t,std::size_t);
void* __wrap_malloc(std::size_t bytes) { if(measuring)++allocation_count; return __real_malloc(bytes); }
void* __wrap_calloc(std::size_t count,std::size_t bytes) { if(measuring)++allocation_count; return __real_calloc(count,bytes); }
void* __wrap_realloc(void* pointer,std::size_t bytes) { if(measuring)++allocation_count; return __real_realloc(pointer,bytes); }
void* __wrap_aligned_alloc(std::size_t alignment,std::size_t bytes) { if(measuring)++allocation_count; return __real_aligned_alloc(alignment,bytes); }
}

namespace {
using namespace kibo::linalg;
struct Region { std::uint32_t offset, bytes; std::size_t alignment; };
template<std::size_t N>
Status validate(const std::array<Region,N>& regions) noexcept {
    const auto heap=emscripten_get_heap_size();
    for (const auto region:regions) {
        if (region.bytes!=0 && (region.offset==0 || region.offset%region.alignment!=0)) return {StatusCode::invalid_layout};
        if (static_cast<std::uint64_t>(region.offset)+region.bytes>heap) return {StatusCode::insufficient_capacity};
    }
    for (std::size_t i=0;i<N;++i) for (std::size_t j=0;j<i;++j) {
        if (regions[i].bytes==0 || regions[j].bytes==0) continue;
        const std::uint64_t a_end=static_cast<std::uint64_t>(regions[i].offset)+regions[i].bytes;
        const std::uint64_t b_end=static_cast<std::uint64_t>(regions[j].offset)+regions[j].bytes;
        if (regions[i].offset<b_end && regions[j].offset<a_end) return {StatusCode::invalid_argument};
    }
    return {};
}
template<class T> std::span<T> span_at(std::uint32_t offset,std::uint32_t bytes) noexcept {
    return {reinterpret_cast<T*>(static_cast<std::uintptr_t>(offset)),bytes/sizeof(T)};
}
std::uint32_t code(Status status) noexcept { return static_cast<std::uint32_t>(status.code); }
void diagnostic(std::uint32_t offset,Status status,double tolerance=0) noexcept {
    const std::uint32_t index=static_cast<std::uint32_t>(status.index),rank=static_cast<std::uint32_t>(status.rank);
    auto* data=reinterpret_cast<std::byte*>(static_cast<std::uintptr_t>(offset));
    std::memcpy(data,&index,4); std::memcpy(data+4,&rank,4); std::memcpy(data+8,&tolerance,8);
}
bool numerical_failure(Status status) noexcept {
    return status.code==StatusCode::non_positive_pivot || status.code==StatusCode::rank_deficient ||
           status.code==StatusCode::arithmetic_failure;
}
}
extern "C" {
std::uint32_t kibo_abi_version() noexcept { return 1; }
std::uint32_t kibo_allocate(std::uint32_t bytes) noexcept {
    return static_cast<std::uint32_t>(reinterpret_cast<std::uintptr_t>(std::malloc(bytes)));
}
void kibo_release(std::uint32_t offset) noexcept {
    std::free(reinterpret_cast<void*>(static_cast<std::uintptr_t>(offset)));
}
std::uint32_t kibo_allocation_count() noexcept { return allocation_count; }
std::uint32_t kibo_calibrate_allocation_probe() noexcept {
    AllocationScope scope;
    void* volatile memory=std::malloc(16);
    std::free(memory);
    return allocation_count;
}
std::uint32_t kibo_matvec(std::uint32_t a,std::uint32_t a_bytes,std::uint32_t m,std::uint32_t n,
    std::uint32_t rs,std::uint32_t cs,std::uint32_t b,std::uint32_t b_bytes,std::uint32_t x,std::uint32_t x_bytes) noexcept {
    AllocationScope scope;
    auto valid=validate(std::array{Region{a,a_bytes,8},Region{b,b_bytes,8},Region{x,x_bytes,8}});
    if (!valid) return code(valid);
    auto input=MatrixView<const double>::checked(span_at<const double>(a,a_bytes),m,n,rs,cs);
    if (!input) return code(input.status());
    if (static_cast<std::uint64_t>(n)*8>b_bytes || static_cast<std::uint64_t>(m)*8>x_bytes) return code({StatusCode::insufficient_capacity});
    return code(matvec_into(input.value(),span_at<const double>(b,b_bytes).first(n),span_at<double>(x,x_bytes).first(m)));
}
std::uint32_t kibo_llt(std::uint32_t a,std::uint32_t a_bytes,std::uint32_t n,std::uint32_t rs,std::uint32_t cs,
    std::uint32_t b,std::uint32_t b_bytes,std::uint32_t x,std::uint32_t x_bytes,
    std::uint32_t factor,std::uint32_t factor_bytes,std::uint32_t work,std::uint32_t work_bytes,
    std::uint32_t diag,std::uint32_t diag_bytes) noexcept {
    AllocationScope scope;
    auto valid=validate(std::array{Region{a,a_bytes,8},Region{b,b_bytes,8},Region{x,x_bytes,8},
        Region{factor,factor_bytes,8},Region{work,work_bytes,8},Region{diag,diag_bytes,8}});
    if (!valid) return code(valid);
    auto input=MatrixView<const double>::checked(span_at<const double>(a,a_bytes),n,n,rs,cs);
    auto storage=MatrixView<double>::checked(span_at<double>(factor,factor_bytes),n,n,n);
    if (!input) return code(input.status());
    if (!storage) return code(storage.status());
    if (static_cast<std::uint64_t>(n)*8>b_bytes || static_cast<std::uint64_t>(n)*8>x_bytes || diag_bytes<16)
        return code({StatusCode::insufficient_capacity});
    auto requirement=llt_solve_requirement(n);
    if (!requirement) return code(requirement.status());
    if (work_bytes<requirement.value().bytes) return code({StatusCode::insufficient_capacity});
    for (auto value:span_at<const double>(b,b_bytes).first(n)) if (!std::isfinite(value)) return code({StatusCode::non_finite_input});
    auto handle=factorize_llt(input.value(),storage.value());
    if (!handle) {
        if (numerical_failure(handle.status())) diagnostic(diag,handle.status());
        return code(handle.status());
    }
    const auto status=solve_into(handle.value(),span_at<const double>(b,b_bytes).first(n),span_at<double>(x,x_bytes).first(n),span_at<std::byte>(work,work_bytes));
    diagnostic(diag,status); return code(status);
}
static std::uint32_t qr_impl(bool refined,std::uint32_t a,std::uint32_t a_bytes,std::uint32_t m,std::uint32_t n,std::uint32_t rs,std::uint32_t cs,
    std::uint32_t b,std::uint32_t b_bytes,std::uint32_t x,std::uint32_t x_bytes,
    std::uint32_t factor,std::uint32_t factor_bytes,std::uint32_t tau,std::uint32_t tau_bytes,
    std::uint32_t permutation,std::uint32_t permutation_bytes,std::uint32_t work,std::uint32_t work_bytes,
    std::uint32_t diag,std::uint32_t diag_bytes) noexcept {
    AllocationScope scope;
    auto valid=validate(std::array{Region{a,a_bytes,8},Region{b,b_bytes,8},Region{x,x_bytes,8},Region{factor,factor_bytes,8},
        Region{tau,tau_bytes,8},Region{permutation,permutation_bytes,4},Region{work,work_bytes,8},Region{diag,diag_bytes,8}});
    if (!valid) return code(valid);
    auto input=MatrixView<const double>::checked(span_at<const double>(a,a_bytes),m,n,rs,cs);
    auto storage=MatrixView<double>::checked(span_at<double>(factor,factor_bytes),m,n,n);
    if (!input) return code(input.status());
    if (!storage) return code(storage.status());
    auto factor_required=qr_factor_requirement(m,n);
    auto solve_required=refined ? qr_refined_solve_requirement(m,n) : qr_solve_requirement(m,n);
    if (!factor_required) return code(factor_required.status());
    if (!solve_required) return code(solve_required.status());
    if (static_cast<std::uint64_t>(m)*8>b_bytes || static_cast<std::uint64_t>(n)*8>x_bytes || diag_bytes<16 ||
        tau_bytes<factor_required.value().tau.bytes || permutation_bytes<factor_required.value().permutation.bytes ||
        work_bytes<factor_required.value().workspace.bytes || work_bytes<solve_required.value().bytes)
        return code({StatusCode::insufficient_capacity});
    for (auto value:span_at<const double>(b,b_bytes).first(m)) if (!std::isfinite(value)) return code({StatusCode::non_finite_input});
    QrDiagnostics observed;
    auto handle=factorize_qr(input.value(),storage.value(),span_at<double>(tau,tau_bytes),span_at<std::size_t>(permutation,permutation_bytes),span_at<std::byte>(work,work_bytes),{},&observed);
    if (!handle) {
        if (numerical_failure(handle.status())) diagnostic(diag,handle.status(),observed.tolerance);
        return code(handle.status());
    }
    const auto status=refined
        ? solve_refined_into(handle.value(),input.value(),span_at<const double>(b,b_bytes).first(m),span_at<double>(x,x_bytes).first(n),span_at<std::byte>(work,work_bytes))
        : solve_into(handle.value(),span_at<const double>(b,b_bytes).first(m),span_at<double>(x,x_bytes).first(n),span_at<std::byte>(work,work_bytes));
    diagnostic(diag,Status{status.code,status.index,observed.rank},observed.tolerance); return code(status);
}
std::uint32_t kibo_qr(std::uint32_t a,std::uint32_t a_bytes,std::uint32_t m,std::uint32_t n,std::uint32_t rs,std::uint32_t cs,
    std::uint32_t b,std::uint32_t b_bytes,std::uint32_t x,std::uint32_t x_bytes,
    std::uint32_t factor,std::uint32_t factor_bytes,std::uint32_t tau,std::uint32_t tau_bytes,
    std::uint32_t permutation,std::uint32_t permutation_bytes,std::uint32_t work,std::uint32_t work_bytes,
    std::uint32_t diag,std::uint32_t diag_bytes) noexcept {
    return qr_impl(false,a,a_bytes,m,n,rs,cs,b,b_bytes,x,x_bytes,factor,factor_bytes,tau,tau_bytes,
                   permutation,permutation_bytes,work,work_bytes,diag,diag_bytes);
}
std::uint32_t kibo_qr_refined(std::uint32_t a,std::uint32_t a_bytes,std::uint32_t m,std::uint32_t n,std::uint32_t rs,std::uint32_t cs,
    std::uint32_t b,std::uint32_t b_bytes,std::uint32_t x,std::uint32_t x_bytes,
    std::uint32_t factor,std::uint32_t factor_bytes,std::uint32_t tau,std::uint32_t tau_bytes,
    std::uint32_t permutation,std::uint32_t permutation_bytes,std::uint32_t work,std::uint32_t work_bytes,
    std::uint32_t diag,std::uint32_t diag_bytes) noexcept {
    return qr_impl(true,a,a_bytes,m,n,rs,cs,b,b_bytes,x,x_bytes,factor,factor_bytes,tau,tau_bytes,
                   permutation,permutation_bytes,work,work_bytes,diag,diag_bytes);
}
}
