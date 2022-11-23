# CMAKE_CUDA_ARCHITECTURES default

This repository contains experimentation with the setting of a default value for `CMAKE_CUDA_ARCHITECTURES` for a CUDA-based library, but allowing users to provide their own.


This is a challenge / requires CMake which occurs both before and after to `project(LANGUAGES CMake)` / `enable_lanaguage(CUDA)` because:

1. Users can provide a value by env var or CMake Cache variable, which should be respected
2. If users do not provide a value, when CUDA is checked / enabled in a sufficiently new version of CMake it will set it to a default value.
    + There is no way to tell if the value was set by a user, or by CMake from this point, without checking prior to the language being enabled.
3. Different CMake versions support different values for this, if we care about CMake `< 3.24`, then 
4. Ideally, the library  / examples should provide a nice error message to the user if their device is too old, rather than just `no CUDA devices found`.
    + With more recent CMakes, which suport `all`, `all-major` and `native` this complicates things though.

