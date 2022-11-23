#include "ccad/ccad.cuh"

#include <cstdio>

namespace ccad {

// Set the value of the minimum CUDA arch from the preproc macro.
#ifdef CCAD_MIN_CUDA_ARCH
    const int MIN_CUDA_ARCH = CCAD_MIN_CUDA_ARCH;
#else
    // if not defined, set it to an invalid value.
    const int MIN_CUDA_ARCH = -1;
#endif

void do_something() {
    printf("do_something\n");
}



}