cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CUDAArch.cmake)

ccad_record_and_inject(ccad)

project(ccad CUDA)

ccad_test()

get_filename_component(ROOT ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)


set(SRC
    ${ROOT}/src/ccad/ccad.cu    
    ${ROOT}/include/ccad/ccad.cuh  

)

add_library(${PROJECT_NAME} STATIC ${SRC})

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)
target_compile_features(${PROJECT_NAME} PUBLIC cuda_std_17)
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_EXTENSIONS OFF)
set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD_REQUIRED ON)
set_target_properties(${PROJECT_NAME} PROPERTIES CUDA_STANDARD_RCXX_STANDARD_REQUIRED ON)

unset(SRC)

# Get the oldest arch, written to ${ccad_minimum_cuda_architecture}
ccad_get_minimum_cuda_architecture()
# Add the minimum cuda architecture as a compiler definition.
target_compile_definitions(${PROJECT_NAME} PRIVATE -DCCAD_MIN_CUDA_ARCH=${ccad_minimum_cuda_architecture})
message(STATUS "ccad_minimum_cuda_architecture: ${ccad_minimum_cuda_architecture}")

target_include_directories(${PROJECT_NAME} PUBLIC "${ROOT}/include")
target_include_directories(${PROJECT_NAME} PRIVATE "${ROOT}/src")
set_property(TARGET ${PROJECT_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)

# Suppress warnings about deprecated architectres (becuase 35 is depreacted, but part of all-major / defaults)
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>")
target_link_options(${PROJECT_NAME} PRIVATE "$<DEVICE_LINK:-Wno-deprecated-gpu-targets>")