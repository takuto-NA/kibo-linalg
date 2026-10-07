#include <kibo/dynamic_matrix.hpp>
#include <cstdio>
#include <cstdlib>
#include <type_traits>

#include "test_check.hpp"
namespace {
struct AllocationState { bool fail=false; int live=0; };
void* allocate(std::size_t bytes, std::size_t, void* context) noexcept {
    auto& state=*static_cast<AllocationState*>(context);
    if (state.fail) return nullptr;
    void* memory=std::malloc(bytes);
    if (memory) ++state.live;
    return memory;
}
void deallocate(void* memory, std::size_t, std::size_t, void* context) noexcept {
    if (memory) { --static_cast<AllocationState*>(context)->live; std::free(memory); }
}
}
int main() {
    using namespace kibo::linalg;
    static_assert(!std::is_copy_constructible_v<DynamicMatrix<double>>);
    static_assert(std::is_nothrow_move_constructible_v<DynamicMatrix<double>>);
    AllocationState state;
    {
        auto created=DynamicMatrix<double>::try_create(2,2,Allocator{allocate,deallocate,&state});
        CHECK(created && state.live==1);
        auto matrix=std::move(created).value();
        matrix(0,0)=4; matrix(1,1)=3;
        state.fail=true;
        CHECK(!matrix.try_clone());
        auto resize=matrix.try_resize(3,3);
        CHECK(!resize && resize.status().code==StatusCode::allocation_failure);
        CHECK(matrix.rows()==2 && matrix(0,0)==4 && state.live==1);
        auto same=matrix.try_resize(2,2);
        CHECK(same && state.live==1); // succeeds even while allocation is forced to fail
        state.fail=false;
        CHECK(matrix.try_resize(3,3));
        CHECK(matrix(0,0)==4 && matrix(1,1)==3 && matrix(2,2)==0 && state.live==1);
        auto cloned=matrix.try_clone();
        CHECK(cloned && state.live==2);
        cloned.value()(0,0)=99;
        CHECK(matrix(0,0)==4);
        auto moved=std::move(matrix);
        CHECK(matrix.rows()==0 && moved(0,0)==4);
        CHECK(moved.try_resize(0,3) && state.live==1);
        state.fail=true;
        auto failed=DynamicMatrix<double>::try_create(1,1,Allocator{allocate,deallocate,&state});
        CHECK(!failed && failed.status().code==StatusCode::allocation_failure);
        auto zero=DynamicMatrix<double>::try_create(0,999,Allocator{allocate,deallocate,&state});
        CHECK(zero && state.live==1);
        auto overflow=DynamicMatrix<double>::try_create(std::numeric_limits<std::size_t>::max(),2);
        CHECK(!overflow && overflow.status().code==StatusCode::size_overflow);
    }
    CHECK(state.live==0);
    auto invalid=DynamicMatrix<double>::try_create(2,2,Allocator{nullptr,deallocate,&state});
    CHECK(!invalid && invalid.status().code==StatusCode::invalid_argument);
    auto defaults=DynamicMatrix<double>::try_create(1,1);
    CHECK(defaults && defaults.value()(0,0)==0);
    auto byte_overflow=DynamicMatrix<double>::try_create(std::numeric_limits<std::size_t>::max()/sizeof(double)+1,1);
    CHECK(!byte_overflow && byte_overflow.status().code==StatusCode::size_overflow);
    auto assigned=std::move(defaults).value();
    auto source=DynamicMatrix<double>::try_create(2,1);
    CHECK(source);
    source.value()(1,0)=7;
    assigned=std::move(source).value();
    CHECK(assigned.rows()==2 && assigned(1,0)==7 && source.value().rows()==0);
    std::puts("explicit ownership, injected allocation failure, resize and clone passed");
}
