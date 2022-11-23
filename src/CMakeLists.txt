cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/CUDAArch.cmake)

ccad_record()

project(ccad CUDA)

ccad_apply()

ccad_test()

get_filename_component(ROOT ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)


set(SRC
    ${ROOT}/src/ccad/ccad.cu    
    ${ROOT}/include/ccad/ccad.cuh  

)

add_library(${PROJECT_NAME} STATIC ${SRC})

unset(SRC)

# Get the oldest arch, to set as a compiler defintiion
ccad_get_oldest_arch()

target_include_directories(${PROJECT_NAME} PUBLIC "${ROOT}/include")
target_include_directories(${PROJECT_NAME} PRIVATE "${ROOT}/src")
set_property(TARGET ${PROJECT_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)

# Suppress warnings about deprecated architectres (becuase 35 is depreacted, but part of all-major / defaults)
target_compile_options(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>")
target_link_options(${PROJECT_NAME} PRIVATE "$<DEVICE_LINK:-Wno-deprecated-gpu-targets>")