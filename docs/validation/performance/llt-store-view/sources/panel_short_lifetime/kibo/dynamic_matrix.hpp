#pragma once
#include <kibo/linalg.hpp>
#include <cstdlib>

namespace kibo::linalg {
struct Allocator {
    using Allocate = void* (*)(std::size_t bytes, std::size_t alignment, void* context) noexcept;
    using Deallocate = void (*)(void* pointer, std::size_t bytes, std::size_t alignment, void* context) noexcept;
    static void* default_allocate(std::size_t bytes, std::size_t, void*) noexcept { return std::malloc(bytes); }
    static void default_deallocate(void* pointer, std::size_t, std::size_t, void*) noexcept { std::free(pointer); }
    Allocate allocate = default_allocate;
    Deallocate deallocate = default_deallocate;
    void* context = nullptr;
};

template<std::floating_point T>
class DynamicMatrix {
    static_assert(alignof(T) <= alignof(std::max_align_t));
    T* data_ = nullptr;
    std::size_t rows_ = 0, cols_ = 0;
    Allocator allocator_;
    DynamicMatrix() noexcept = default;
    void release() noexcept {
        if (data_) allocator_.deallocate(data_, rows_ * cols_ * sizeof(T), alignof(T), allocator_.context);
        data_ = nullptr; rows_ = 0; cols_ = 0;
    }
public:
    DynamicMatrix(const DynamicMatrix&) = delete;
    DynamicMatrix& operator=(const DynamicMatrix&) = delete;
    DynamicMatrix(DynamicMatrix&& other) noexcept
        : data_(std::exchange(other.data_,nullptr)), rows_(std::exchange(other.rows_,0)),
          cols_(std::exchange(other.cols_,0)), allocator_(other.allocator_) {}
    DynamicMatrix& operator=(DynamicMatrix&& other) noexcept {
        if (this != &other) {
            release();
            data_ = std::exchange(other.data_,nullptr);
            rows_ = std::exchange(other.rows_,0); cols_ = std::exchange(other.cols_,0);
            allocator_ = other.allocator_;
        }
        return *this;
    }
    ~DynamicMatrix() { release(); }

    static Result<DynamicMatrix> try_create(std::size_t rows, std::size_t cols, Allocator allocator = {}) noexcept {
        if (!allocator.allocate || !allocator.deallocate) return StatusCode::invalid_argument;
        const auto maximum = std::numeric_limits<std::size_t>::max();
        if (cols != 0 && rows > maximum / cols) return StatusCode::size_overflow;
        const auto count = rows * cols;
        if (count > maximum / sizeof(T)) return StatusCode::size_overflow;
        DynamicMatrix matrix;
        matrix.rows_ = rows; matrix.cols_ = cols; matrix.allocator_ = allocator;
        if (count != 0) {
            void* memory = allocator.allocate(count * sizeof(T), alignof(T), allocator.context);
            if (!memory) return StatusCode::allocation_failure;
            if (reinterpret_cast<std::uintptr_t>(memory) % alignof(T) != 0) {
                allocator.deallocate(memory, count * sizeof(T), alignof(T), allocator.context);
                return StatusCode::invalid_layout;
            }
            matrix.data_ = static_cast<T*>(memory);
            for (std::size_t i = 0; i < count; ++i) matrix.data_[i] = 0;
        }
        return matrix;
    }
    std::size_t rows() const noexcept { return rows_; }
    std::size_t cols() const noexcept { return cols_; }
    T& operator()(std::size_t row, std::size_t col) noexcept {
        assert(row < rows_ && col < cols_); return data_[row * cols_ + col];
    }
    const T& operator()(std::size_t row, std::size_t col) const noexcept {
        assert(row < rows_ && col < cols_); return data_[row * cols_ + col];
    }
    MatrixView<T> view() noexcept {
        return MatrixView<T>::checked({data_,rows_ * cols_},rows_,cols_,cols_ == 0 ? 1 : cols_).value();
    }
    MatrixView<const T> const_view() const noexcept {
        return MatrixView<const T>::checked({data_,rows_ * cols_},rows_,cols_,cols_ == 0 ? 1 : cols_).value();
    }
    Result<MatrixView<T>> try_resize(std::size_t rows, std::size_t cols) noexcept {
        if (rows == rows_ && cols == cols_) return view();
        auto created = try_create(rows,cols,allocator_);
        if (!created) return created.status().code;
        auto replacement = std::move(created).value();
        const auto kept_rows = rows < rows_ ? rows : rows_;
        const auto kept_cols = cols < cols_ ? cols : cols_;
        for (std::size_t i = 0; i < kept_rows; ++i)
            for (std::size_t j = 0; j < kept_cols; ++j) replacement(i,j) = (*this)(i,j);
        *this = std::move(replacement);
        return view();
    }
    Result<DynamicMatrix> try_clone() const noexcept {
        auto cloned = try_create(rows_,cols_,allocator_);
        if (!cloned) return cloned.status().code;
        for (std::size_t i = 0; i < rows_ * cols_; ++i) cloned.value().data_[i] = data_[i];
        return std::move(cloned).value();
    }
};
} // namespace kibo::linalg
