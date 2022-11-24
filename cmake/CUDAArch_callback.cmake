
# If there were any existing project includes prior to this being injected (stored in a parent scoep cmake var)

# this callback requires CUDA to be enabeld, otherwise 
if(NOT CMAKE_CUDA_COMPILER_LOADED)
    # @todo different error if called manually or by injected cmake? 
    message(FATAL_ERROR
        "  ccad_apply_and_inject only works if CUDA is an enabled language on the specified project\n"
        "  Please add LANGUAGES CUDA to the project command, or ccad_record();project();ccad_apply()")
endif()

# ensure the relevant command is available, this isn't required for tpyical use, as this will only be injected from the file it includes.
if (NOT COMMAND ccad_apply)
    include("${CMAKE_CURRENT_LIST_DIR}/CUDAArch.cmake")
endif()

# Call the appropraite command to set CMAKE_CUDA_ARCHITECTURES to the user-provided value, the exising value, or a sane libray-provided defualt
ccad_apply()
