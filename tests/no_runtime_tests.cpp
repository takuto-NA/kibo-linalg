#include <kibo/linalg.hpp>
#include <array>
#include <cstdio>

#if defined(_CPPUNWIND) || defined(_CPPRTTI)
#error Consumer must compile without exception handling or RTTI.
#endif
#if !defined(_MSC_VER) && (defined(__EXCEPTIONS) || defined(__GXX_RTTI))
#error Consumer must compile without exception handling or RTTI.
#endif

template<class T> concept FloatingValue = std::floating_point<T>;
static_assert(FloatingValue<double> && !FloatingValue<int>);

int main() {
    kibo::linalg::StaticMatrix<double,2,2> a;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> output{};
    const auto status=kibo::linalg::matvec_into(a.view(),std::span<const double>{b},std::span<double>{output});
    if (!status || output[0]!=6 || output[1]!=7) return 1;
    std::puts("C++20 concepts/span; exceptions and RTTI disabled; Ab=[6,7]");
}
