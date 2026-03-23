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
- ninja
- meson
# Build
1. Put VASP .tgz file in the root
2. `make`
3. Enjoy

# Issues
- libbeef version is not fixed, as it does not have tag.
- pspfft version is not fixed, as it does not have tag.
- ELPA with intel toolchain may produce executable stack, which may connect to code injection.
