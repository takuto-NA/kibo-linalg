idf_component_register(SRCS "main.cpp" INCLUDE_DIRS "." REQUIRES esp_system freertos heap)
target_compile_features(${COMPONENT_LIB} PRIVATE cxx_std_20)
set_target_properties(${COMPONENT_LIB} PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED YES CXX_EXTENSIONS NO)
set_source_files_properties(main.cpp PROPERTIES COMPILE_OPTIONS "-std=c++20")
target_compile_options(${COMPONENT_LIB} PRIVATE -fno-exceptions -fno-rtti)
target_include_directories(${COMPONENT_LIB} PRIVATE
    "${CMAKE_CURRENT_LIST_DIR}/../../../include"
    "${CMAKE_CURRENT_LIST_DIR}/../..")
