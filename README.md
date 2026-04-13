# Prerequisites
## Compilers
- Fortran compiler (At least fortran 2008)
- C preprocessor
- C++ compiler
- MPI compiler wrappers for all three above. (Make sure they point to correct compilers)
## Libraries
- BLAS
- LAPACK
- FFTW / oneAPI FFT
## Build tools (Using conda environment is recommended)
- make
- cmake
- ninja
- meson
# Build
1. Clone this repository and update the necessary submodules.
    - If you want to download all the dependencies (VASP optional packages), clone this repository first, then initialize the submodules by `git submodule init` and then `git submodule update`. You can also clone this repository & all the dependencies at the same time with `git clone <repository url> --recurse-submodules`.
    - If you want to apply only some of the VASP optional packages, use `git submodule update <list of submodule paths>` after the initialization of submodules.
1. Put VASP .tgz file in the project root
1. Set variables for the followings. (Do edit makefile.)  
    - VASP source code tarball file path (`VASP`)  
    - Optional features of VASP (`OPTIONALS`)  
    - Compiler/linker setups
        - Compilers (`CC`, `CXX`, and `FC` for c, c++ and fortran compilers)  
        - MPI wrappers (`MPICC`, `MPICXX`, and `MPIFC`)  
        - Common compiler/linker flags (`CFLAGS`, `FCFLAGS`, and `LDFLAGS`)  
        - Compiler/linker flags for each library (`CFLAGS_*`, `FCFLAGS_*`, and `LDFLAGS_*`)  
    - Base makefile.include template file (`BASE`)  
1. `make` (use `make -j` for parallel build)
1. Enjoy

> Once you've compiled all the dependency VASP packages, you may patch the vasp source code however you want, if needed. Navigate into `vaspenv/build/<vasp_tarball_name>`, remove the binary files with `make veryclean`, patch the source code, and finally build VASP again with `make DEPS=1 -j` (no need to re-build all the other submodules!).

# Issues
- Currently, using link time optimization is not possible (at least for LLVM toolchains), as fortran's declaration is not enough to determine its type.
- ELPA with intel toolchain may produce executable stack, which may connect to code injection. (`LDFLAGS=-Wl,-z,noexecstack` should fix the security issue, but might break something.)
- libbeef version is not fixed, as it does not have tag.
- pspfft version is not fixed, as it does not have tag.