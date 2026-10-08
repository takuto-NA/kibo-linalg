#include <kibo/linalg.hpp>
#include <array>
#include <cmath>
#include <cstdio>
#include <span>

int main() {
    using namespace kibo::linalg;
    StaticMatrix<double, 2, 2> a;
    a(0, 0) = 4; a(0, 1) = 1;
    a(1, 0) = 1; a(1, 1) = 3;
    const std::array<double, 2> b{1, 2};
    std::array<double, 2> product{};
    const auto status = matvec_into(a.const_view(),
        std::span<const double>{b}, std::span<double>{product});
    if (!status || product[0] != 6 || product[1] != 7) {
        std::fputs("2x2 public matvec failed\n", stderr);
        return 1;
    }
    std::puts("2x2 public matvec passed");
    std::array<double, 12> padded{1,2,3,99,4,5,6,99,7,8,9,99};
    auto external = MatrixView<const double>::checked(padded, 3, 3, 4);
    if (!external) return 2;
    StaticMatrix<double,3,3> gram;
    if (!matmul_into(external.value().transpose(), external.value(), gram.view())) return 3;
    const std::array<double,9> expected{66,78,90,78,93,108,90,108,126};
    for (std::size_t i=0; i<3; ++i)
        for (std::size_t j=0; j<3; ++j)
            if (std::abs(gram(i,j)-expected[i*3+j]) > 1e-14+1e-12*std::abs(expected[i*3+j])) return 4;
    if (!fill_into(gram.view(), 5.0) || gram(2,1) != 5.0) return 5;
    if (!identity_into(gram.view()) || gram(1,1) != 1.0 || gram(2,1) != 0.0) return 6;
    auto corner = external.value().submatrix(1,1,2,2);
    if (!corner || !copy_into(corner.value(), a.view()) || a(0,0) != 5 || a(1,1) != 9) return 7;
    StaticMatrix<double,2,2> scaled;
    if (!scale_into(a.const_view(),2.0,scaled.view()) || scaled(1,1)!=18) return 8;
    if (!add_into(a.const_view(),scaled.const_view(),a.view()) || a(1,1)!=27) return 9;
    if (!sub_into(a.const_view(),scaled.const_view(),a.view()) || a(1,1)!=9) return 10;
    if (!add_diagonal_inplace(a.view(),2.0) || a(0,0)!=7 || a(0,1)!=6 || a(1,1)!=11) return 11;
    const std::array<double,2> huge{3e300,4e300}, tiny{3e-300,4e-300};
    const auto large_norm=stable_norm2(std::span<const double>{huge});
    const auto small_norm=stable_norm2(std::span<const double>{tiny});
    const auto scalar_product=dot(std::span<const double>{b},std::span<const double>{b});
    if (!large_norm || std::abs(large_norm.value()/5e300-1)>1e-12 ||
        !small_norm || std::abs(small_norm.value()/5e-300-1)>1e-12 ||
        !scalar_product || scalar_product.value()!=5) return 12;
    // Rejected inputs must leave a prepared output unchanged.
    product={81,82};
    a(1,1)=std::numeric_limits<double>::quiet_NaN();
    if (matvec_into(a.const_view(),std::span<const double>{b},std::span<double>{product}).code !=
        StatusCode::non_finite_input || product != std::array<double,2>{81,82}) return 13;
    a(1,1)=1;
    if (matvec_into(a.const_view(),std::span<const double>{b}.first(1),std::span<double>{product}).code !=
        StatusCode::invalid_shape || product != std::array<double,2>{81,82}) return 14;
    if (MatrixView<double>::checked(padded,3,3,1,1).status().code!=StatusCode::invalid_layout ||
        MatrixView<double>::checked(padded,3,3,0).status().code!=StatusCode::invalid_layout ||
        MatrixView<double>::checked(padded,3,3,10).status().code!=StatusCode::insufficient_capacity ||
        MatrixView<double>::checked(padded,3,3,std::numeric_limits<std::size_t>::max()).status().code!=StatusCode::size_overflow)
        return 15;
    auto empty=MatrixView<double>::checked({},0,3,3);
    if (!empty || !fill_into(empty.value(),1.0) || empty.value().submatrix(0,0,1,1)) return 16;
    auto const_overlap=MatrixView<const double>::checked(padded,3,3,1,1);
    if (!const_overlap || const_overlap.value()(2,2)!=4) return 17;
    a(0,0)=std::numeric_limits<double>::max(); a(0,1)=0;
    const std::array<double,2> overflow_vector{2,1};
    if (matvec_into(a.const_view(),std::span<const double>{overflow_vector},std::span<double>{product}).code!=
        StatusCode::arithmetic_failure) return 18;
    std::array<double,4> column_major{1,3,2,4};
    auto column_view=MatrixView<const double>::checked(column_major,2,2,1,2);
    if (!column_view || !copy_into(column_view.value(),a.view()) || a(0,1)!=2 || a(1,0)!=3) return 19;
    alignas(double) std::array<std::byte,64> raw_storage{};
    auto misaligned=std::span<double>{reinterpret_cast<double*>(raw_storage.data()+1),2};
    if (MatrixView<double>::checked(misaligned,1,1,1).status().code!=StatusCode::invalid_layout) return 20;
    // Every validation path scans before writing, including a late infinity.
    column_major[3]=std::numeric_limits<double>::infinity();
    if (copy_into(column_view.value(),a.view()).code!=StatusCode::non_finite_input || a(1,1)!=4) return 21;
    std::array<double,6> left_data{1,2,3,4,5,6}, right_data{7,8,9,10,11,12};
    auto left=MatrixView<const double>::checked(left_data,2,3,3);
    auto right=MatrixView<const double>::checked(right_data,3,2,2);
    if (!left || !right || !matmul_into(left.value(),right.value(),a.view()) ||
        a(0,0)!=58 || a(0,1)!=64 || a(1,0)!=139 || a(1,1)!=154) return 22;
    auto zero_left=MatrixView<const double>::checked({},2,0,1);
    auto zero_right=MatrixView<const double>::checked({},0,2,2);
    if (!zero_left || !zero_right || !matmul_into(zero_left.value(),zero_right.value(),a.view()) ||
        a(0,0)!=0 || a(1,1)!=0) return 23;
    std::puts("stride/transpose/rectangular arithmetic and rejection contracts passed");
    return 0;
}
