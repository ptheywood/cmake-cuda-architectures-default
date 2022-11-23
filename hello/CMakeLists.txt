cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

project(hello CUDA)

message("${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")

add_executable(${PROJECT_NAME} src/main.cu)

target_link_libraries(${PROJECT_NAME} ccad)