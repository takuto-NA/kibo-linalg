#pragma once

#include <array>
#include <cassert>
#include <cmath>
#include <concepts>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <numeric>
#include <optional>
#include <span>
#include <type_traits>
#include <utility>

namespace kibo::linalg {

enum class StatusCode {
    ok, invalid_shape, invalid_layout, invalid_argument, insufficient_capacity,
    size_overflow, allocation_failure, non_finite_input, non_positive_pivot,
    rank_deficient, arithmetic_failure, invalid_factor
};

struct [[nodiscard]] Status {
    StatusCode code = StatusCode::ok;
    std::size_t index = 0;
    std::size_t rank = 0;
    constexpr explicit operator bool() const noexcept { return code == StatusCode::ok; }
};

template<class T>
class [[nodiscard]] Result {
    Status status_;
    std::optional<T> value_;
public:
    static_assert(std::is_nothrow_move_constructible_v<T>);
    Result(StatusCode error) noexcept : status_{error} { assert(error != StatusCode::ok); }
    Result(Status error) noexcept : status_(error) { assert(!error); }
    Result(T value) noexcept : value_(std::move(value)) {}
    explicit operator bool() const noexcept { return static_cast<bool>(status_); }
    Status status() const noexcept { return status_; }
    T& value() & noexcept { assert(value_); return *value_; }
    const T& value() const & noexcept { assert(value_); return *value_; }
    T&& value() && noexcept { assert(value_); return std::move(*value_); }
};

template<class T>
concept Scalar = std::floating_point<std::remove_const_t<T>>;

template<Scalar T>
class MatrixView {
    template<Scalar> friend class MatrixView;
    std::span<T> storage_;
    std::size_t rows_ = 0, cols_ = 0, row_stride_ = 1, col_stride_ = 1;
    MatrixView(std::span<T> storage, std::size_t rows, std::size_t cols,
               std::size_t rs, std::size_t cs) noexcept
        : storage_(storage), rows_(rows), cols_(cols), row_stride_(rs), col_stride_(cs) {}
public:
    MatrixView() noexcept = default;
    template<Scalar U> requires (std::is_const_v<T> && std::same_as<std::remove_const_t<T>, U>)
    MatrixView(MatrixView<U> other) noexcept
        : MatrixView(other.storage_, other.rows_, other.cols_, other.row_stride_, other.col_stride_) {}

    // Let MSVC propagate common unit strides through this checked factory.
#if defined(_MSC_VER)
    __forceinline
#endif
    static Result<MatrixView> checked(std::span<T> storage, std::size_t rows,
                                     std::size_t cols, std::size_t rs, std::size_t cs = 1) noexcept {
        if (rs == 0 || cs == 0) return StatusCode::invalid_layout;
        if (reinterpret_cast<std::uintptr_t>(storage.data()) % alignof(T) != 0)
            return StatusCode::invalid_layout;
        if (rows == 0 || cols == 0) return MatrixView(storage, rows, cols, rs, cs);
        const auto max = std::numeric_limits<std::size_t>::max();
        if ((rs != 1 && rows - 1 > max / rs) || (cs != 1 && cols - 1 > max / cs))
            return StatusCode::size_overflow;
        const auto last_row = (rows - 1) * rs, last_col = (cols - 1) * cs;
        if (last_col >= max - last_row) return StatusCode::size_overflow;
        if (last_row + last_col + 1 > storage.size()) return StatusCode::insufficient_capacity;
        if constexpr (!std::is_const_v<T>) {
            // gcd(stride,1)==1; contiguous rows/columns need only one comparison.
            if (cs == 1) {
                if (rows > 1 && cols > rs) return StatusCode::invalid_layout;
            } else if (rs == 1) {
                if (cols > 1 && rows > cs) return StatusCode::invalid_layout;
            } else {
                const auto divisor = std::gcd(rs, cs);
                if (rows > cs / divisor && cols > rs / divisor) return StatusCode::invalid_layout;
            }
        }
        return MatrixView(storage, rows, cols, rs, cs);
    }
    std::size_t rows() const noexcept { return rows_; }
    std::size_t cols() const noexcept { return cols_; }
    std::size_t row_stride() const noexcept { return row_stride_; }
    std::size_t col_stride() const noexcept { return col_stride_; }
    T& operator()(std::size_t row, std::size_t col) const noexcept {
        assert(row < rows_ && col < cols_);
        return storage_[row * row_stride_ + col * col_stride_];
    }
    MatrixView transpose() const noexcept { return MatrixView(storage_, cols_, rows_, col_stride_, row_stride_); }
    Result<MatrixView> submatrix(std::size_t row, std::size_t col,
                                 std::size_t rows, std::size_t cols) const noexcept {
        if (row > rows_ || col > cols_ || rows > rows_ - row || cols > cols_ - col)
            return StatusCode::invalid_shape;
        if (rows == 0 || cols == 0) return MatrixView({}, rows, cols, row_stride_, col_stride_);
        return MatrixView(storage_.subspan(row * row_stride_ + col * col_stride_), rows, cols, row_stride_, col_stride_);
    }
};

template<std::floating_point T, std::size_t Rows, std::size_t Cols>
class StaticMatrix {
    static_assert(Cols == 0 || Rows <= std::numeric_limits<std::size_t>::max() / Cols);
    std::array<T, Rows * Cols> storage_{};
public:
    T& operator()(std::size_t row, std::size_t col) noexcept {
        assert(row < Rows && col < Cols); return storage_[row * Cols + col];
    }
    const T& operator()(std::size_t row, std::size_t col) const noexcept {
        assert(row < Rows && col < Cols); return storage_[row * Cols + col];
    }
    MatrixView<T> view() noexcept {
        return MatrixView<T>::checked(storage_, Rows, Cols, Cols == 0 ? 1 : Cols).value();
    }
    MatrixView<const T> const_view() const noexcept {
        return MatrixView<const T>::checked(storage_, Rows, Cols, Cols == 0 ? 1 : Cols).value();
    }
};

namespace detail {
template<std::floating_point T>
class ScaledSquares {
    T scale_=0, sum_squares_=1;
public:
    void add(T value) noexcept {
        const T magnitude=std::abs(value);
        if (magnitude==0) return;
        if (scale_<magnitude) {
            const T ratio=scale_/magnitude;
            sum_squares_=1+sum_squares_*ratio*ratio;
            scale_=magnitude;
        } else {
            const T ratio=magnitude/scale_;
            sum_squares_+=ratio*ratio;
        }
    }
    T norm() const noexcept { return scale_*std::sqrt(sum_squares_); }
};
template<Scalar T>
bool finite(MatrixView<T> a) noexcept {
    for (std::size_t i = 0; i < a.rows(); ++i)
        for (std::size_t j = 0; j < a.cols(); ++j)
            if (!std::isfinite(a(i,j))) return false;
    return true;
}
template<Scalar A, Scalar B>
bool same_shape(MatrixView<A> a, MatrixView<B> b) noexcept {
    return a.rows() == b.rows() && a.cols() == b.cols();
}
} // namespace detail

template<Scalar T>
Status matvec_into(MatrixView<T> a, std::span<const std::remove_const_t<T>> x,
                   std::span<std::remove_const_t<T>> output) noexcept {
    if (a.cols() != x.size() || a.rows() != output.size()) return {StatusCode::invalid_shape};
    if (!detail::finite(a)) return {StatusCode::non_finite_input};
    for (auto value : x) if (!std::isfinite(value)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < a.rows(); ++i) {
        std::remove_const_t<T> sum = 0;
        for (std::size_t j = 0; j < a.cols(); ++j) sum += a(i,j) * x[j];
        if (!std::isfinite(sum)) return {StatusCode::arithmetic_failure};
        output[i] = sum;
    }
    return {};
}

template<Scalar A, Scalar B, std::floating_point T>
requires (std::same_as<std::remove_const_t<A>, T> && std::same_as<std::remove_const_t<B>, T>)
Status matmul_into(MatrixView<A> a, MatrixView<B> b, MatrixView<T> output) noexcept {
    if (a.cols() != b.rows() || output.rows() != a.rows() || output.cols() != b.cols())
        return {StatusCode::invalid_shape};
    if (!detail::finite(a) || !detail::finite(b)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < output.rows(); ++i) {
        for (std::size_t j = 0; j < output.cols(); ++j) {
            T sum = 0;
            for (std::size_t k = 0; k < a.cols(); ++k) sum += a(i,k) * b(k,j);
            if (!std::isfinite(sum)) return {StatusCode::arithmetic_failure};
            output(i,j) = sum;
        }
    }
    return {};
}

template<std::floating_point T>
Status fill_into(MatrixView<T> output, T value) noexcept {
    if (!std::isfinite(value)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < output.rows(); ++i)
        for (std::size_t j = 0; j < output.cols(); ++j) output(i,j) = value;
    return {};
}

template<std::floating_point T>
Status identity_into(MatrixView<T> output) noexcept {
    for (std::size_t i = 0; i < output.rows(); ++i)
        for (std::size_t j = 0; j < output.cols(); ++j) output(i,j) = i == j ? T{1} : T{0};
    return {};
}

template<Scalar A, std::floating_point T>
requires std::same_as<std::remove_const_t<A>, T>
Status copy_into(MatrixView<A> a, MatrixView<T> output) noexcept {
    if (!detail::same_shape(a, output)) return {StatusCode::invalid_shape};
    if (!detail::finite(a)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < output.rows(); ++i)
        for (std::size_t j = 0; j < output.cols(); ++j) output(i,j) = a(i,j);
    return {};
}

namespace detail {
template<Scalar A, Scalar B, std::floating_point T, class Operation>
Status binary_into(MatrixView<A> a, MatrixView<B> b, MatrixView<T> output, Operation operation) noexcept {
    if (!same_shape(a,b) || !same_shape(a,output)) return {StatusCode::invalid_shape};
    if (!finite(a) || !finite(b)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < output.rows(); ++i) {
        for (std::size_t j = 0; j < output.cols(); ++j) {
            const T value = operation(a(i,j), b(i,j));
            if (!std::isfinite(value)) return {StatusCode::arithmetic_failure};
            output(i,j) = value;
        }
    }
    return {};
}
} // namespace detail

template<Scalar A, Scalar B, std::floating_point T>
requires (std::same_as<std::remove_const_t<A>, T> && std::same_as<std::remove_const_t<B>, T>)
Status add_into(MatrixView<A> a, MatrixView<B> b, MatrixView<T> output) noexcept {
    return detail::binary_into(a,b,output,[](T x, T y) noexcept { return x+y; });
}
template<Scalar A, Scalar B, std::floating_point T>
requires (std::same_as<std::remove_const_t<A>, T> && std::same_as<std::remove_const_t<B>, T>)
Status sub_into(MatrixView<A> a, MatrixView<B> b, MatrixView<T> output) noexcept {
    return detail::binary_into(a,b,output,[](T x, T y) noexcept { return x-y; });
}
template<Scalar A, std::floating_point T>
requires std::same_as<std::remove_const_t<A>, T>
Status scale_into(MatrixView<A> a, T scale, MatrixView<T> output) noexcept {
    if (!detail::same_shape(a,output)) return {StatusCode::invalid_shape};
    if (!std::isfinite(scale) || !detail::finite(a)) return {StatusCode::non_finite_input};
    for (std::size_t i = 0; i < output.rows(); ++i) {
        for (std::size_t j = 0; j < output.cols(); ++j) {
            const T value = a(i,j) * scale;
            if (!std::isfinite(value)) return {StatusCode::arithmetic_failure};
            output(i,j) = value;
        }
    }
    return {};
}
template<std::floating_point T>
Status add_diagonal_inplace(MatrixView<T> a, T value) noexcept {
    if (!std::isfinite(value) || !detail::finite(a)) return {StatusCode::non_finite_input};
    const auto count = a.rows() < a.cols() ? a.rows() : a.cols();
    for (std::size_t i = 0; i < count; ++i) {
        const T result = a(i,i) + value;
        if (!std::isfinite(result)) return {StatusCode::arithmetic_failure};
        a(i,i) = result;
    }
    return {};
}

template<std::floating_point T>
Result<T> dot(std::span<const T> a, std::span<const T> b) noexcept {
    if (a.size() != b.size()) return StatusCode::invalid_shape;
    for (auto value : a) if (!std::isfinite(value)) return StatusCode::non_finite_input;
    for (auto value : b) if (!std::isfinite(value)) return StatusCode::non_finite_input;
    T sum = 0;
    for (std::size_t i = 0; i < a.size(); ++i) sum += a[i] * b[i];
    if (!std::isfinite(sum)) return StatusCode::arithmetic_failure;
    return sum;
}

template<std::floating_point T>
Result<T> stable_norm2(std::span<const T> a) noexcept {
    detail::ScaledSquares<T> sum;
    for (const auto value : a) {
        if (!std::isfinite(value)) return StatusCode::non_finite_input;
        sum.add(value);
    }
    const T result = sum.norm();
    if (!std::isfinite(result)) return StatusCode::arithmetic_failure;
    return result;
}

} // namespace kibo::linalg
