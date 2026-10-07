#include <kibo/linalg.hpp>
#include "test_check.hpp"
#include <algorithm>
#include <array>
#include <limits>

int main() {
    using namespace kibo::linalg;
    std::array<double,512> data{};
    for (std::size_t i=0;i<data.size();++i) data[i]=static_cast<double>(i);
    // Enumerate physical offsets independently of the factory's GCD test.
    // Test unit/general strides, overlapping read-only views, empty shapes,
    // and capacity failures that must take precedence over mutable aliasing.
    for (std::size_t rows=0;rows<=7;++rows) for (std::size_t cols=0;cols<=7;++cols)
        for (std::size_t rs=0;rs<=12;++rs) for (std::size_t cs=0;cs<=12;++cs) {
            std::array<bool,512> seen{};
            bool overlap=false;
            std::size_t needed=0;
            for (std::size_t i=0;i<rows;++i) for (std::size_t j=0;j<cols;++j) {
                const auto offset=i*rs+j*cs;
                overlap|=seen[offset];seen[offset]=true;
                needed=std::max(needed,offset+1);
            }
            const std::array<std::size_t,8> capacities{0,1,7,31,128,512,needed,needed==0?0:needed-1};
            for (auto capacity:capacities) {
                const auto common=rs==0 || cs==0 ? StatusCode::invalid_layout :
                    needed>capacity ? StatusCode::insufficient_capacity : StatusCode::ok;
                auto mutable_view=MatrixView<double>::checked(std::span<double>{data}.first(capacity),rows,cols,rs,cs);
                auto readonly=MatrixView<const double>::checked(std::span<const double>{data}.first(capacity),rows,cols,rs,cs);
                const auto expected_mutable=common==StatusCode::ok && overlap ? StatusCode::invalid_layout : common;
                CHECK(mutable_view.status().code==expected_mutable);
                CHECK(readonly.status().code==common);
                if (readonly) {
                    CHECK(readonly.value().rows()==rows && readonly.value().cols()==cols);
                    CHECK(readonly.value().row_stride()==rs && readonly.value().col_stride()==cs);
                    for (std::size_t i=0;i<rows;++i) for (std::size_t j=0;j<cols;++j)
                        CHECK(readonly.value()(i,j)==static_cast<double>(i*rs+j*cs));
                }
                if (mutable_view) {
                    CHECK(mutable_view.value().rows()==rows && mutable_view.value().cols()==cols);
                    CHECK(mutable_view.value().row_stride()==rs && mutable_view.value().col_stride()==cs);
                    for (std::size_t i=0;i<rows;++i) for (std::size_t j=0;j<cols;++j)
                        CHECK(mutable_view.value()(i,j)==static_cast<double>(i*rs+j*cs));
                }
            }
        }
    const auto max=std::numeric_limits<std::size_t>::max();
    struct Boundary { std::size_t rows,cols,rs,cs; StatusCode expected; };
    const std::array<Boundary,12> boundaries{{
        {max,1,1,1,StatusCode::insufficient_capacity},
        {1,max,1,1,StatusCode::insufficient_capacity},
        {max,2,1,1,StatusCode::size_overflow},
        {2,max,1,1,StatusCode::size_overflow},
        {max/2+1,1,2,1,StatusCode::insufficient_capacity},
        {max/2+2,1,2,1,StatusCode::size_overflow},
        {1,max/2+1,1,2,StatusCode::insufficient_capacity},
        {1,max/2+2,1,2,StatusCode::size_overflow},
        {2,1,max,1,StatusCode::size_overflow},
        {1,2,1,max,StatusCode::size_overflow},
        {0,max,max,max,StatusCode::ok},
        {max,0,max,max,StatusCode::ok}}};
    for (auto b:boundaries) {
        CHECK(MatrixView<double>::checked(data,b.rows,b.cols,b.rs,b.cs).status().code==b.expected);
        CHECK(MatrixView<const double>::checked(data,b.rows,b.cols,b.rs,b.cs).status().code==b.expected);
    }
    std::puts("matrix view offset/alias enumeration and size boundaries passed");
}
