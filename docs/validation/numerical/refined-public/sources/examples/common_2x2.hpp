#pragma once
#include <kibo/llt.hpp>
#include <kibo/qr_refined.hpp>
#include <array>
#include <cmath>

namespace kibo::examples {
struct Common2x2 {
    linalg::StaticMatrix<double,2,2> a, factor_storage;
    std::array<double,2> b{1,2}, product{}, solution{};
    alignas(double) std::array<std::byte,16> workspace{};
    std::array<double,2> tau{},refined_solution{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,80> refined_workspace{};
    linalg::Status run() noexcept {
        a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
        auto status=linalg::matvec_into(a.const_view(),std::span<const double>{b},std::span<double>{product});
        if (!status) return status;
        auto factor=linalg::factorize_llt(a.const_view(),factor_storage.view());
        if (!factor) return factor.status();
        status=linalg::solve_into(factor.value(),std::span<const double>{b},std::span<double>{solution},workspace);
        if (!status) return status;
        auto qr=linalg::factorize_qr(a.const_view(),factor_storage.view(),tau,permutation,refined_workspace);
        if (!qr) return qr.status();
        return linalg::solve_refined_into(qr.value(),a.const_view(),b,refined_solution,refined_workspace);
    }
    bool correct() const noexcept {
        const auto close=[](double actual,double expected) noexcept {
            return std::abs(actual-expected)<=1e-14+1e-12*std::abs(expected);
        };
        return close(product[0],6) && close(product[1],7) && close(solution[0],1.0/11) && close(solution[1],7.0/11)
            && close(refined_solution[0],1.0/11) && close(refined_solution[1],7.0/11);
    }
};
static_assert(sizeof(Common2x2)<=4096);
}
