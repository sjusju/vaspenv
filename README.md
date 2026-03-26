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
1. Put VASP .tgz file in the project root
1. Set variables for the followings. (Do edit makefile.)  
Compilers (`CC`, `CXX`, and `FC` for c, c++ and fortran compilers)  
MPI wrappers (`MPICC`, `MPICXX`, and `MPIFC`)  
Common compiler/linker flags (`CFLAGS`, `FCFLAGS`, and `LDFLAGS`)  
Compiler/linker flags for each library (`CFLAGS_*`, `FCFLAGS_*`, and `LDFLAGS_*`)  
VASP source code tarball (`VASP`)  
Base makefile.include template file (`BASE`)  
Optional features of VASP (`OPTIONALS`)  
1. `make`
1. Enjoy

# Issues
- libbeef version is not fixed, as it does not have tag.
- pspfft version is not fixed, as it does not have tag.
- ELPA with intel toolchain may produce executable stack, which may connect to code injection. (`LDFLAG=-Wl,-z,noexecstack` should fix the security issue, but might break something.)
- DFT-D4 and simple-DFT-D3 uses `meson` build system, which may be incompatible with intel's `ifx -flto`. (Should be fixed for `meson` version 1.9.0 and above.)
