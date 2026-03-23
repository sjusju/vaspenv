#!/bin/bash

export CC=mpiicx
export CXX=mpiicpx
export FC=mpiifx
export F90=mpiifx
export F77=mpiifx
export CFLAGS="-march=native"
export FCFLAGS="-I${MKLROOT}/include -march=native"
export FFLAGS="-I${MKLROOT}/include -march=native"
export LDFLAGS="-L${MKLROOT}/lib -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl"

rm -rf build
mkdir -p build
rsync -a --exclude='.*' dependencies/* build/
rsync -a dependencies/libmbd build/
cd build/
# tar -xf ../vasp*.tgz

# CC FC CFLAGS FFLAGS LDFLAGS, uses mpi
cd hdf5
cmake -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DHDF5_ENABLE_PARALLEL=ON \
      -DBUILD_STATIC_LIBS=ON \
      -DHDF5_BUILD_FORTRAN=ON
cmake --build build --config Release -j
# ctest build -C Release
cmake --install build --prefix $(pwd)/../install
cd ..

# FC, no mpi
cd wannier90
touch make.inc
make -j lib \
     "F90=${FC}" \
     "FCOPTS=-O2" \
     "LDOPTS=-O2" \
     "LIBS=-L${MKLROOT}/lib -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lpthread"
mkdir -p ../install/lib
cp libwannier.a ../install/lib
cd ..

# CC FC CFLAGS FCFLAGS LDFLAGS, no mpi
cd libxc
autoreconf -i
./configure
make -j
make install prefix=$(pwd)/../install
cd ..

# CC CFLAGS, no mpi
cd libbeef
./configure
make -j
make install prefix=$(pwd)/../install
cd ..

# CC FC, no mpi
cd dftd4
meson setup _build --prefix=$(pwd)/../install
meson compile -C _build
meson install -C _build
cd ..

# CC FC, no mpi
cd simple-dftd3
meson setup _build --prefix=$(pwd)/../install
meson compile -C _build
meson install -C _build
cd ..

# CC FC CFLAGS FCFLAGS LDFLAGS, uses mpi
cd elpa
./autogen.sh
./configure
make -j
make install prefix=$(pwd)/../install
cd ..

# CC FC CFLAGS, no mpi
cd libmbd
cmake -B build -DENABLE_SCALAPACK_MPI=OFF -DBUILD_SHARED_LIBS=OFF
cmake --build build
cmake --install build --prefix $(pwd)/../install
cd ..

# use mpi
cd pspfft
echo "" > Config/Makefile_Config
make -j -C Build \
	"C_COMPILE=${CC} -c" \
	"C_DEBUG= -g -Wall" \
	"C_OPTIMIZE= -O3" \
	"FORTRAN_COMPILE=${FC} -c" \
	"FORTRAN_DEBUG= -g -gdwarf-2 -ffpe-trap=invalid,zero,overflow -Wall" \
	"FORTRAN_OPTIMIZE= -O3" \
	"LINK=${FC}" \
	"INCLUDE_FFTW= -I/opt/intel/oneapi/mkl/latest/include/fftw" \
	"LIBRARY_FFTW=-qmkl"
make -C Build install INSTALL=$(pwd)/../install
cd ..

# use mpi
cd dl_mg_code_public
cat > platforms/vaspenv.inc << EOF
FC= mpiifx
FFLAGS= -O3 -module \$(OBJDIR) -I\$(LIBDIR) -I\$(OBJDIR) -DMPI
EOF
make PLATFORM=vaspenv -j
mkdir -p ../install/include
mkdir -p ../install/lib
cp lib/dl_mg.mod ../install/include
cp lib/libdlmg.a ../install/lib
cd ..