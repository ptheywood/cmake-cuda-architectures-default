#include <cstdio>

#include "ccad/ccad.cuh"

int main() {
    printf("main\n");
    ccad::do_something();
    printf("ccad::MIN_CUDA_ARCH %d\n", ccad::MIN_CUDA_ARCH);
    #ifdef CCAD_MIN_CUDA_ARCH
        printf("CCAD_MIN_CUDA_ARCH is defined\n");
    #else
        printf("CCAD_MIN_CUDA_ARCH is not defined!\n");
    #endif
    return EXIT_SUCCESS;
}