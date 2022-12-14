cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CUDAArchitectures.cmake)

ccad_init_cuda_architectures(PROJECT hello NO_VALIDATE_ARCHITECTURES)

project(hello CUDA)

# Print the current value of CMAKE_CUDA_ARCHITECTURES as a test
message(STATUS "${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")

add_executable(${PROJECT_NAME} src/main.cu)

# Add the static library if building this inner project standalone. I.e. flamegpu examples
if (NOT TARGET ccad)
    get_filename_component(ROOT ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)
    add_subdirectory("${ROOT}/src" "${PROJECT_BINARY_DIR}/ccad")
endif()

target_link_libraries(${PROJECT_NAME} ccad)

# Suppress warnings about deprecated architectres (becuase 35 is depreacted, but part of all-major / defaults)
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>")
target_link_options(${PROJECT_NAME} PRIVATE "$<DEVICE_LINK:-Wno-deprecated-gpu-targets>")