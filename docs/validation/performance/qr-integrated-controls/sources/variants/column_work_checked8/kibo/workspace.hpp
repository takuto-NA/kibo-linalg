#pragma once
#include <kibo/linalg.hpp>

namespace kibo::linalg {
struct WorkspaceRequirement { std::size_t bytes=0, alignment=alignof(double); };
struct FactorRequirement { WorkspaceRequirement factor, workspace; };
namespace detail {
inline Result<WorkspaceRequirement> double_requirement(std::size_t count) noexcept {
    if (count > std::numeric_limits<std::size_t>::max()/sizeof(double)) return StatusCode::size_overflow;
    return WorkspaceRequirement{count*sizeof(double),alignof(double)};
}
inline Result<std::span<double>> workspace_doubles(std::span<std::byte> storage, WorkspaceRequirement requirement) noexcept {
    if (storage.size() < requirement.bytes) return StatusCode::insufficient_capacity;
    if (requirement.bytes!=0 && reinterpret_cast<std::uintptr_t>(storage.data())%requirement.alignment!=0)
        return StatusCode::invalid_layout;
    return std::span<double>{reinterpret_cast<double*>(storage.data()),requirement.bytes/sizeof(double)};
}
} // namespace detail
} // namespace kibo::linalg
