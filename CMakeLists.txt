cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

project(CCAD LANGUAGES NONE)

# Delayed cuda support, mirroring upstream. I.e. we can't inject into project here.
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
    enable_language(CXX)
endif()
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
endif()

# Exit if older CUDA.
set(MIN_CUDA_VER "11.0")
if(CMAKE_CUDA_COMPILER_VERSION VERSION_LESS MIN_CUDA_VER)
    message(FATAL_ERROR "CUDA >= ${MIN_CUDA_VER} required. ${CMAKE_CUDA_COMPILER_VERSION} found")
endif()
unset(MIN_CUDA_VER)


message("${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")





# # Add the library project
add_subdirectory(src)

# # add the binary project
add_subdirectory(hello)