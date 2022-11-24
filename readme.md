# CMAKE_CUDA_ARCHITECTURES default

This repository contains experimentation with the setting of a default value for [`CMAKE_CUDA_ARCHITECTURES`](https://cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html) for a CUDA-based library, but allowing users to provide their own.

`CMAKE_CUDA_ARCHITECTURES` is a CMake 3.18 addition which allows handling of CUDA device code generation flags (i.e `--gencode`). 

It supports:

+ CMake List (semi-colon separated string) of:
  + Compute Capability numbers, producing real and virtual code for each. I.e. `"52;60"`
  + Real and virtual specifiers for particular architectures. I.e. `"50-real;52-real;52-virtual"`
  + A mix of the above
+ Special values:
  + `all` from CMake 3.23, all major and minor real architectures + highest virtual for the selected CUDA version
  + `all-major` from CMake 3.23, all major real architectures + highest virtual for the selected CUDA version
  + `native` from CMake 3.24, which just builds for all architectures visible to the system configuring CMake (i.e. a device is required to compile)

From CMake 3.25, this also supports the `lto_52` type targets, when `CMAKE_INTERPROCEDURAL_OPTIMIZATION` is set, or the target property `INTERPROCEDURAL_OPTIMIZATION` is set.

---

Providing a default is non trivial and requires CMake which occurs both before and after to `project(LANGUAGES CUDA)` / `enable_lanaguage(CUDA)`, unlike the majority of CMake features which are expected to be after a `project` method because:

1. Users can provide a value by env var or CMake Cache variable, which should be respected
2. If users do not provide a value, when CUDA is checked / enabled in a sufficiently new version of CMake it will set it to a default value.
    + There is no way to tell if the value was set by a user, or by CMake from this point, without checking prior to the language being enabled.
    + Different CMake versions support different values for this, if we care about CMake `< 3.24`, then we can't just use `all-major` for the default.
3. This needs to work for `project(LANGUAGES CUDA)` and `project(LANGUAGES NONE); enable_language(CUDA)`.
4. Ideally, the library  / examples should provide a nice error message to the user if their device is too old, rather than just `no CUDA devices found`.
    + With more recent CMakes, which suport `all`, `all-major` and `native`, this is more complicated.

The repository is set up to mirror the [FLAMEGPU/FLAMEGPU2](https://github.com/FLAMEGPU/FLAMEGPU2) structure having a central (static) library, with one or more binaries for good measure.

There are additional CMake `message` statements included in this repository that are not necessary in a real-world use-case, but make CMake features behaviour obvious without the need to build or run code.

## Requirements

+ CMake >= 3.18
+ CUDA >= 11.0

## CMake Configuration and Building

The CMake native CUDA architectures settings are controlled by the `CMAKE_CUDA_ARCHITECTURES` Cache variable (i.e. from the CLI, the GUI or early `SET` commands) or the `CUDAARCHS` environment variable.

If unspecified, without custom handling this would default to the default for the used CUDA version, i.e. `52` for CUDA 11.x, but with custom handling should be something else (i.e. `all-major` or a list of architectures)

e.g.

```bash
cmake -S . -B build
# Should output something other than 52
```

Specifying SM 60 and SM 70 via the CLI should override this

```bash
cmake -S . -B build -DCMAKE_CUDA_ARCHITECTURES="60;70"
# should output 60;70
```

The environment variable can be used, but it can be overridden by via the CLI too

```bash
CUDAARCHS="61" cmake -S . -B build
# should output 61
```

```bash
CUDAARCHS="61" cmake -S . -B build -DCMAKE_CUDA_ARCHITECTURES="60;70"
# should output 60;70
```

If a user has previsouly set a value, but wants to return the default, they should be able to do this via `-UCMAKE_CUDA_ARCHITECTURES` or `-DCMAKE_CUDA_ARCHITECTURES=""`

```bash
cmake -S . -B build -DCMAKE_CUDA_ARCHITECTURES="60;70"
# should output 60;70
cmake -S . -B build -UCMAKE_CUDA_ARCHITECTURES
# should have output the longer default
```
