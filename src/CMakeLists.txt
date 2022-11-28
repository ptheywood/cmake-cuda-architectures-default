cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CUDAArchitectures.cmake)

ccad_init_cuda_architectures(PROJECT ccad)

project(ccad CUDA)

# Print the current value of CMAKE_CUDA_ARCHITECTURES as a test
message(STATUS "${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")

get_filename_component(ROOT ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)
set(SRC
    ${ROOT}/src/ccad/ccad.cu    
    ${ROOT}/include/ccad/ccad.cuh  
)

add_library(${PROJECT_NAME} STATIC ${SRC})
unset(SRC)

# Get the oldest arch, written to ${ccad_minimum_cuda_architecture}
ccad_get_minimum_cuda_architecture(min_arch)
# Add the minimum cuda architecture as a compiler definition.
target_compile_definitions(${PROJECT_NAME} PRIVATE -DCCAD_MIN_CUDA_ARCH=${min_arch})

# Print out the minimum cuda arch being forwarded to the compiler. 
message(STATUS "min_arch: ${min_arch}")

target_include_directories(${PROJECT_NAME} PUBLIC "${ROOT}/include")
target_include_directories(${PROJECT_NAME} PRIVATE "${ROOT}/src")
set_property(TARGET ${PROJECT_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)

# Suppress warnings about deprecated architectres (becuase 35 is depreacted, but part of all-major / defaults)
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>")
target_link_options(${PROJECT_NAME} PRIVATE "$<DEVICE_LINK:-Wno-deprecated-gpu-targets>")