#include <kibo/linalg.hpp>
#include <array>
#include <cstdio>
#include <cstdlib>
#if defined(_MSC_VER) && defined(_DEBUG)
#include <crtdbg.h>
namespace {
bool measuring=false;
std::size_t allocations=0;
int allocation_hook(int type, void*, std::size_t, int, long, const unsigned char*, int) {
    if (measuring && (type==_HOOK_ALLOC || type==_HOOK_REALLOC)) ++allocations;
    return 1;
}
}
#endif
int main() {
#if defined(_MSC_VER) && defined(_DEBUG)
    const auto previous=_CrtSetAllocHook(allocation_hook);
    measuring=true;
    void* volatile calibration=std::malloc(16);
    measuring=false;
    std::free(calibration);
    if (allocations==0) { std::fputs("allocation probe failed calibration\n",stderr); return 1; }
    kibo::linalg::StaticMatrix<double,2,2> a, output;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> product{};
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
    }
    measuring=false; _CrtSetAllocHook(previous);
    std::printf("prepared basic operations: CRT allocations=%zu\n",allocations);
    return !ok || allocations!=0;
#else
    std::puts("CRT allocation probe requires MSVC Debug; no measurement in this configuration");
    return 77;
#endif
}
