# Prerequisites
## Compilers
- Fortran compiler (At least fortran 2008)
- C preprocessor
- C++ compiler
## Libraries
- BLAS
- LAPACK
- FFTW / oneAPI FFT
## Build tools
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
1. `make` (use `make -j` for faster compile with running multiple jobs in parallel)
1. Enjoy

> Once you've compiled all the dependency VASP packages, you may patch the vasp source code however you want, if needed. Navigate into `vaspenv/build/vasp.<version number>/`, remove the binary files with `make veryclean`, patch the source code, and finally build VASP again with `make DEPS=1 -j` (no need to re-build all the other submodules!).

# Issues
- MPI wrappers may not be installed as the default `MPICC`, `MPICXX`, and `MPIFC` in `makefile`. Check if those are installed by console commands `mpiicx -v`, `mpiicpx -v`, and `mpiifort -v`. If not installed, use the default compiler by changing the makefile as `MPICC= mpiicc -cc=icx`, `MPICXX= mpiicpc -cxx=icpx`, and `MPIFC= mpiifort -fc=ifx`.
- DFT-D4 and simple-DFT-D3 uses `meson` build system, which may be incompatible with intel's `ifx -flto`. (Should be fixed for `meson` version 1.9.0 and above.)
    - We recommend to create a new python environment (conda, etc.) and install `meson` with `conda install meson`. `meson -v` should print version 1.9.0 or above. Proceed the build procedure as usual.
- ELPA with intel toolchain may produce executable stack, which may connect to code injection. (`LDFLAGS=-Wl,-z,noexecstack` should fix the security issue, but might break something.)
- libbeef version is not fixed, as it does not have tag.
- pspfft version is not fixed, as it does not have tag.