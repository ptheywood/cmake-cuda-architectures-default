cmake_minimum_required(VERSION 3.18...3.25 FATAL_ERROR)

# Detect if there are user provided architectures or not, form the cache or environment
set(arch_from_user FALSE)
if(DEFINED CMAKE_CUDA_ARCHITECTURES OR DEFINED ENV{CUDAARCHS})
    set(arch_from_user TRUE)
endif()

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

# --- code that needs triggering within project, or after enable. 
# If the user did not provide any architectures, set it to a default, which is CMake and CUDA version specific
if(NOT arch_from_user OR CMAKE_CUDA_ARCHITECTURES STREQUAL "")
    set(default_archs "35;50;60;70;80")
    if(CMAKE_CUDA_COMPILER_VERISON VERSION_GREATER_EQUAL 11.8.0)
        list(APPEND "90")
    endif()
    # Set the value
    set(CMAKE_CUDA_ARCHITECTURES ${default_archs})

    #unset local vars
    unset(default_archs)
endif()

#/---
message("${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")





# # Add the library project
add_subdirectory(src)

# # add the binary project
add_subdirectory(hello)