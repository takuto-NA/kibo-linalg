#include <kibo/llt.hpp>
extern "C" __declspec(noinline) bool public_finite(double value) noexcept {
    return kibo::linalg::detail::llt_is_finite(value);
}
