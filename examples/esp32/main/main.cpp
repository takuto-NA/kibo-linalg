#include "common_2x2.hpp"
#include <esp_heap_caps.h>
#include <esp_heap_trace.h>
#include <esp_idf_version.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <cstdio>

#if defined(__EXCEPTIONS) || defined(__GXX_RTTI)
#error ESP32 consumer requires exceptions and RTTI disabled
#endif
static_assert(__cplusplus==202002L,"ESP32 consumer must actually compile in C++20 mode");
namespace {
static kibo::examples::Common2x2 problem;
static heap_trace_record_t trace_records[64];
void report(const char* phase,kibo::linalg::Status status,bool accepted,
            std::size_t calibration_allocations,std::size_t allocations,unsigned free_stack) {
    std::printf("{\"phase\":\"%s\",\"target\":\"%s\",\"idf\":\"%s\",\"status\":%u,\"accepted\":%s,"
        "\"numeric_bytes\":%zu,\"calibration_allocations\":%zu,\"allocations\":%zu,\"stack_budget_bytes\":8192,\"stack_free_min_bytes\":%u,"
        "\"heap_free_bytes\":%zu,\"heap_largest_bytes\":%zu,\"matvec\":[%.17g,%.17g],\"solve\":[%.17g,%.17g],\"refined_solve\":[%.17g,%.17g]}\n",
        phase,CONFIG_IDF_TARGET,esp_get_idf_version(),static_cast<unsigned>(status.code),accepted?"true":"false",
        sizeof(problem),calibration_allocations,allocations,free_stack,heap_caps_get_free_size(MALLOC_CAP_INTERNAL|MALLOC_CAP_8BIT),
        heap_caps_get_largest_free_block(MALLOC_CAP_INTERNAL|MALLOC_CAP_8BIT),problem.product[0],problem.product[1],problem.solution[0],problem.solution[1],
        problem.refined_solution[0],problem.refined_solution[1]);
}
void worker(void*) {
    std::puts("kibo: measuring prepared 2x2 computation");
    const auto initialized=heap_trace_init_standalone(trace_records,64);
    const auto calibration_started=initialized==ESP_OK ? heap_trace_start(HEAP_TRACE_ALL) : initialized;
    void* volatile calibration_pointer=calibration_started==ESP_OK
        ? heap_caps_malloc(16,MALLOC_CAP_INTERNAL|MALLOC_CAP_8BIT) : nullptr;
    heap_caps_free(calibration_pointer);
    const auto calibration_stopped=calibration_started==ESP_OK ? heap_trace_stop() : calibration_started;
    heap_trace_summary_t calibration{};
    const auto calibrated=calibration_stopped==ESP_OK ? heap_trace_summary(&calibration) : calibration_stopped;
    const bool calibration_ok=calibrated==ESP_OK && calibration.total_allocations>0 && !calibration.has_overflowed;
    // start clears the calibration records. Only prepared computation is measured.
    const auto started=calibration_ok ? heap_trace_start(HEAP_TRACE_ALL) : ESP_ERR_INVALID_STATE;
    kibo::linalg::Status status{kibo::linalg::StatusCode::invalid_argument};
    if (started==ESP_OK) {
        for (int repeat=0;repeat<100;++repeat) {
            status=problem.run();
            if (!status) break;
        }
    }
    const auto stopped=started==ESP_OK ? heap_trace_stop() : started;
    heap_trace_summary_t measured{};
    const auto summarized=stopped==ESP_OK ? heap_trace_summary(&measured) : stopped;
    const auto allocations=measured.total_allocations;
    // Exercise the full formatter before sampling stack high-water, outside the heap trace.
    report("probe",status,false,calibration.total_allocations,allocations,
           static_cast<unsigned>(uxTaskGetStackHighWaterMark(nullptr)));
    const auto free_stack=uxTaskGetStackHighWaterMark(nullptr); // ESP-IDF returns bytes
    const bool accepted=calibration_ok && started==ESP_OK && stopped==ESP_OK && summarized==ESP_OK && status &&
        problem.correct() && allocations==0 && !measured.has_overflowed && free_stack>=2048;
    report("final",status,accepted,calibration.total_allocations,allocations,static_cast<unsigned>(free_stack));
    vTaskDelete(nullptr);
}
}
extern "C" void app_main() {
    if (xTaskCreate(worker,"kibo",8192,nullptr,5,nullptr)!=pdPASS)
        std::puts("{\"accepted\":false,\"error\":\"task_creation\"}");
}
