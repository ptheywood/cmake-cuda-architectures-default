cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/CUDAArch.cmake)

ccad_record()
# ccad_record_and_inject(CCAD) # Ths will fail, as the project must enable CUDA.

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

ccad_apply()

ccad_test()

# # Add the library project
add_subdirectory(src)
include(CMakeDependentOption)
# Detect if this is the top-level project or if it has been included by add_subdirectory. PROJECT_IS_TOP_LEVEL requires CMake 3.21
if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}")
  set(CCAD_PROJECT_IS_TOP_LEVEL ON)
else()
  set(CCAD_PROJECT_IS_TOP_LEVEL OFF)
endif()

# CMake option to control building of the hello example, so this can be included in other repos with the same target name? 
cmake_dependent_option(CCAD_BUILD_HELLO "Enable building examples/boids_bruteforce" OFF "CCAD_PROJECT_IS_TOP_LEVEL" OFF)

if(CCAD_BUILD_HELLO)
    # add the binary project
    add_subdirectory(hello)
endif()