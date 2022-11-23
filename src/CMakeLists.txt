cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

project(ccad CUDA)

message("${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")

get_filename_component(ROOT ${CMAKE_CURRENT_LIST_DIR}/.. REALPATH)


set(SRC
    ${ROOT}/src/ccad/ccad.cu    
    ${ROOT}/include/ccad/ccad.cuh  

)

add_library(${PROJECT_NAME} STATIC ${SRC})

unset(SRC)

target_include_directories(${PROJECT_NAME} PUBLIC "${ROOT}/include")
target_include_directories(${PROJECT_NAME} PRIVATE "${ROOT}/src")
set_property(TARGET ${PROJECT_NAME} PROPERTY POSITION_INDEPENDENT_CODE ON)
