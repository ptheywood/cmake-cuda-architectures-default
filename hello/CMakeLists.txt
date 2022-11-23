cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

project(hello CUDA)

message("${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")

add_executable(${PROJECT_NAME} src/main.cu)

target_link_libraries(${PROJECT_NAME} ccad)

# Suppress warnings about deprecated architectres (becuase 35 is depreacted, but part of all-major / defaults)
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>")
target_link_options(${PROJECT_NAME} PRIVATE "$<DEVICE_LINK:-Wno-deprecated-gpu-targets>")