include_guard(GLOBAL)

function(ccad_record)
    # Detect if there are user provided architectures or not, form the cache or environment
    set(arch_from_env_or_cache FALSE)
    if(DEFINED CMAKE_CUDA_ARCHITECTURES OR DEFINED ENV{CUDAARCHS})
        set(arch_from_env_or_cache TRUE)
    endif()
    # message(STATUS "recorded arch from user? ${arch_from_env_or_cache}")
    # promote the stored value to parent(file) scope for later use. This might need to become internal cache, but hopefully not.
    set(arch_from_env_or_cache ${arch_from_env_or_cache} PARENT_SCOPE)
endfunction()

function(ccad_apply)
    # message("apply ${arch_from_env_or_cache}")

    # @todo - setting the languge to CUDA sets the dfefault, but doesn't validate the user provided a sane option otherwise. We should validate that here rather than waiting till the first all to nvcc, and optionally set it to the default? (probably not)

    # If the user did not provide any architectures, set it to a default, which is CMake and CUDA version specific
    if(arch_from_env_or_cache AND NOT CMAKE_CUDA_ARCHITECTURES STREQUAL "")#
        message(STATUS "early exit")
        return()
    endif()

    # If we're using CMake >= 3.23, we can just use all-major, though we then have to find the minimum a different way?
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.23")
        set(CMAKE_CUDA_ARCHITECTURES "all-major" PARENT_SCOPE)

    else()
        # For CMake < 3.23, we have to make our own all-major equivalent.
        # @todo - could we query nvcc here to find all architectures, then pull the major ones plus oldest arch?
        set(default_archs "35;50;60;70;80")
        # @todo - rather than building a list up, we could start with an ideal list, then remove 90 if not supported via nvcc output?
        if(CMAKE_CUDA_COMPILER_VERISON VERSION_GREATER_EQUAL 11.8.0)
            list(APPEND "90")
        endif()
        # We actually want real for each arch, then virtual for the final, but only for library-provided values, to only embed one arch worth of ptx.
        # So grab the last element of the list
        list(GET default_archs -1 final)
        # append -real to each element, to not embed ptx for that arch too
        list(TRANSFORM default_archs APPEND "-real")
        # add the -virtual version of the final element
        list(APPEND default_archs "${final}-virtual")
        # Set the value
        set(CMAKE_CUDA_ARCHITECTURES ${default_archs} PARENT_SCOPE)
        #unset local vars
        unset(default_archs)
    endif()
endfunction()

function(ccad_test)
    # Print out the current value, as an easy way to check during cmake development.
    message(STATUS "${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")
endfunction()