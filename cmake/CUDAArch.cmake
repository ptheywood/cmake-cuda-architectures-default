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

# @todo - make validation default but optional
function(ccad_apply)
    # message("apply ${arch_from_env_or_cache}")

    # @todo - setting the languge to CUDA sets the dfefault, but doesn't validate the user provided a sane option otherwise. We should validate that here rather than waiting till the first all to nvcc, and optionally set it to the default? (probably not)
    # CMake 3.24 doesnt' vlaidate all/all-major properpyl, so if its one of the 3 knwon versions we should block it being a list too.

    # If we already have a cuda architetures value, validate it as CMake doesn't.
    if(arch_from_env_or_cache AND NOT CMAKE_CUDA_ARCHITECTURES STREQUAL "")
        # Get the number or architectures specified
        list(LENGTH CMAKE_CUDA_ARCHITECTURES arch_count)
        # native requires CMake >= 3.24, and must be the only option.
        if("native" IN_LIST CMAKE_CUDA_ARCHITECTURES)
            # Error if CMake is too old
            if(CMAKE_VERSION VERSION_LESS 3.24)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `native` requires CMake >= 3.24.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
            # Error if there are multiple architectures specified.
            if(arch_count GREATER 1)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `native` must be the only value specified.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
        endif()
        # all requires 3.23, and must be the sole value.
        if("all" IN_LIST CMAKE_CUDA_ARCHITECTURES)
            # Error if CMake is too old
            if(CMAKE_VERSION VERSION_LESS 3.23)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `all` requires CMake >= 3.23.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
            # Error if there are multiple architectures specified.
            if(arch_count GREATER 1)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `all` must be the only value specified.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
        endif()
        # all-major requires 3.23, and must be the sole value.
        if("all-major" IN_LIST CMAKE_CUDA_ARCHITECTURES)
            # Error if CMake is too old
            if(CMAKE_VERSION VERSION_LESS 3.23)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `all-major` requires CMake >= 3.23.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
            # Error if there are multiple architectures specified.
            if(arch_count GREATER 1)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `all-major` must be the only value specified.\n"
                    " CMAKE_CUDA_ARCHITECTURES=\"${CMAKE_CUDA_ARCHITECTURES}\"")
            endif()
        endif()

        # Cmake 3.18+ expects a list of 1 or more <sm>, <sm>-real or <sm>-virtual.
        # CMake isn't aware of the exact SMS supported by the CUDA version afiak, but we can query nvcc --help and extract the output. Only query this once.
        if(NOT DEFINED SUPPORTED_CUDA_ARCHITECTURES_NVCC)
            execute_process(COMMAND ${CMAKE_CUDA_COMPILER} "--help" OUTPUT_VARIABLE NVCC_HELP_STR ERROR_VARIABLE NVCC_HELP_STR)
            # Match all comptue_XX or sm_XXs
            string(REGEX MATCHALL "'(sm|compute)_[0-9]+'" SUPPORTED_CUDA_ARCHITECTURES_NVCC "${NVCC_HELP_STR}" )
            # Strip just the numeric component
            string(REGEX REPLACE "'(sm|compute)_([0-9]+)'" "\\2" SUPPORTED_CUDA_ARCHITECTURES_NVCC "${SUPPORTED_CUDA_ARCHITECTURES_NVCC}" )
            # Remove dupes and sort to build the correct list of supported CUDA_ARCH.
            list(REMOVE_DUPLICATES SUPPORTED_CUDA_ARCHITECTURES_NVCC)
            list(REMOVE_ITEM SUPPORTED_CUDA_ARCHITECTURES_NVCC "")
            list(SORT SUPPORTED_CUDA_ARCHITECTURES_NVCC)
            # Store the supported arch's once and only once. This could be a cache  var given the cuda compiler should not be able to change without clearing th cache?
            set(SUPPORTED_CUDA_ARCHITECTURES_NVCC ${SUPPORTED_CUDA_ARCHITECTURES_NVCC} PARENT_SCOPE)
        endif()
        # Iterate the options, checking each is allowed based on the nvcc help output, erroring if not.
        # First transform the list removing -real/-virtual, to simplify logic within the loop.
        set(archs ${CMAKE_CUDA_ARCHITECTURES})
        list(TRANSFORM archs REPLACE "(\-real|\-virtual)" "")
        foreach(ARCH IN LISTS archs)
            if(NOT ARCH IN_LIST SUPPORTED_CUDA_ARCHITECTURES_NVCC)
                message(FATAL_ERROR
                    " CMAKE_CUDA_ARCHITECTURES value `${ARCH}` is not supported by nvcc ${CMAKE_CUDA_COMPILER_VERSION}.\n"
                    " Supported architectures based on nvcc --help: \n"
                    "   ${SUPPORTED_CUDA_ARCHITECTURES_NVCC}\n")
            endif()
        endforeach()
        unset(archs)
        # If no errors yet, we're good to go.
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

function(ccad_get_minimum_cuda_architecture)
    # assuming CMAKE_CUDA_ARCHITECTURES is set, extract the oldest architecture from it? - This is not required, but provides much more helpful error messages (for downstream users). It might not be possible with all-major, all & native.

    if(DEFINED CMAKE_CUDA_ARCHITECTURES)
        # If the list contains all, all-major or native, do something.
        if("native" IN_LIST CMAKE_CUDA_ARCHITECTURES)
            message("@todo handle oldest arch from native ${CMAKE_CUDA_ARCHITECTURES}")
        elseif("all-major" IN_LIST CMAKE_CUDA_ARCHITECTURES OR "all" IN_LIST CMAKE_CUDA_ARCHITECTURES)
            message("@todo handle oldest arch from all/all-major ${CMAKE_CUDA_ARCHITECTURES}")
        else()
            # Otherwise it should just be a list of one or more <sm>/<sm>-real/<sm-virtual>
            # Copy the list
            set(archs ${CMAKE_CUDA_ARCHITECTURES})
            # Replace occurances of -real and -virtual
            list(TRANSFORM archs REPLACE "(\-real|\-virtual)" "")
            # Sort the list numerically (natural option
            list(SORT archs COMPARE NATURAL ORDER ASCENDING)
            # Get the first element
            list(GET archs 0 lowest)
            # Set the lowest arch to a parent scoped cache variable which can be accessed externally.
            # @todo - use an argument instead, so users can put it where they want?
            set(ccad_minimum_cuda_architecture ${lowest} PARENT_SCOPE)
        endif()
    else()
        message(FATAL_ERROR "ccad_get_minimum_cuda_architecture: CMAKE_CUDA_ARCHITECTURES is not set / is empty")
    endif()

endfunction()

function(ccad_test)
    # Print out the current value, as an easy way to check during cmake development.
    message(STATUS "${CMAKE_CURRENT_LIST_FILE} :: ${CMAKE_CUDA_ARCHITECTURES}")
endfunction()