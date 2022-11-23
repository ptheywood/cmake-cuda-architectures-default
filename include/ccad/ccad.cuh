#pragma once

namespace ccad {

void do_something();

/**
 * namespaced constant withthe minimum cuda version, which can be accessed from linked exucuatbles which don't have the definition
 */
extern const int MIN_CUDA_ARCH;

}