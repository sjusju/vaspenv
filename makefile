# Compilers
CC= icx
CXX= icpx
FC= ifx
# MPI wrappers
MPICC= mpiicx
MPICXX= mpiicpx
MPIFC= mpiifx
# Binary tools (required for link time optimization)
AR=ar
NM=nm
RANLIB=ranlib
# Common flags (Only put flags common to all libraries.)
CFLAGS= -march=native -O2 -g -Bsymbolic
FCFLAGS= -march=native -O2 -g -Bsymbolic
LDFLAGS= -Wl,-z,noexecstack -Wl,-Bsymbolic
# BLAS
CFLAGS_BLAS= -I"${MKLROOT}/include"
FCFLAGS_BLAS= -I"${MKLROOT}/include"
LDFLAGS_BLAS= -L"${MKLROOT}/lib" -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
# LAPACK
CFLAGS_LAPACK= -I"${MKLROOT}/include"
FCFLAGS_LAPACK= -I"${MKLROOT}/include"
LDFLAGS_LAPACK= -L"${MKLROOT}/lib" -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
# BLACS
CFLAGS_BLACS= -I"${MKLROOT}/include"
FCFLAGS_BLACS= -I"${MKLROOT}/include"
LDFLAGS_BLACS= -L"${MKLROOT}/lib" -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl
# SCALAPACK
CFLAGS_SCALAPACK= -I"${MKLROOT}/include"
FCFLAGS_SCALAPACK= -I"${MKLROOT}/include"
LDFLAGS_SCALAPACK= -L"${MKLROOT}/lib" -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl
# FFTW
CFLAGS_FFTW= -I"${MKLROOT}/include/fftw"
FCFLAGS_FFTW= -I"${MKLROOT}/include/fftw"
LDFLAGS_FFTW= -L"${MKLROOT}/lib" -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
#
VASP=vasp.6.6.0.tgz
BASE=makefile.include.oneapi
OPTIONALS=hdf5 wannier90 libxc libbeef dftd4 simple-dftd3 elpa libmbd scpc

export CC
export CXX
export FC
export CFLAGS
export FCFLAGS
export LDFLAGS
export AR
export NM
export RANLIB

export PATH :=${CURDIR}/build/tools:${PATH}

all: vasp

clean:
	rm -rf build

vasp: optionals
	cd build && tar -xf "../${VASP}"
	cp "build/${VASP:.tgz=}/arch/${BASE}" "build/${VASP:.tgz=}/makefile.include"
	echo "\ninclude ${CURDIR}/build/makefiles/*" >> "build/${VASP:.tgz=}/makefile.include"
	cd "build/${VASP:.tgz=}" && ${MAKE} DEPS=1

optionals: ${OPTIONALS}
	find build/install/include -type f -exec mv {} build/include \;

hdf5: build/lib/libhdf5_fortran.a build/lib/libhdf5_f90cstub.a build/lib/libhdf5.a
	echo "\
	CPP_OPTIONS += -DVASP_HDF5\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
wannier90: build/lib/libwannier.a
	echo "\
	CPP_OPTIONS += -DVASP2WANNIER90\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
libxc: build/lib/libxcf03.a build/lib/libxc.a
	echo "\
	CPP_OPTIONS += -DUSELIBXC\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
libbeef: build/lib/libbeef.a
	echo "\
	CPP_OPTIONS += -Dlibbeef\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
dftd4: build/lib/libdftd4.a
	echo "\
	CPP_OPTIONS += -DDFTD4\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
simple-dftd3: build/lib/libs-dftd3.a
	echo "\
	CPP_OPTIONS += -DSDFTD3\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
elpa: build/lib/libelpa.a
	echo "\
	CPP_OPTIONS += -DELPA\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
libmbd: build/lib/libmbd.a
	echo "\
	CPP_OPTIONS += -DLIBMBD\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk
scpc: build/lib/libdlmg.a build/lib/libpspfft.a
	echo "\
	CPP_OPTIONS += -DSCPC\n\
	LLIBS       += ${^:%=\"${CURDIR}/%\"}\n\
	" > build/makefiles/$@.mk

build/lib/libhdf5_fortran.a: build/install/lib/libhdf5_fortran.a
	cp $< $@
build/lib/libhdf5_f90cstub.a: build/install/lib/libhdf5_f90cstub.a
	cp $< $@
build/lib/libhdf5.a: build/install/lib/libhdf5.a
	cp $< $@
build/install/lib/libhdf5_fortran.a build/install/lib/libhdf5_f90cstub.a build/install/lib/libhdf5.a &: build/hdf5
	CC="${MPICC}" \
	FC="${MPIFC}" \
	CFLAGS="${CFLAGS}" \
	FFLAGS="${FCFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	cmake build/hdf5 \
	-B build/hdf5/build \
	-DCMAKE_BUILD_TYPE=Release \
	-DHDF5_ENABLE_PARALLEL=ON \
	-DBUILD_STATIC_LIBS=ON \
	-DHDF5_BUILD_FORTRAN=ON
	cmake --build build/hdf5/build --config Release
	cmake --install build/hdf5/build --prefix "${CURDIR}/build/install"
build/lib/libwannier.a: build/install/lib/libwannier.a
	cp $< $@
build/install/lib/libwannier.a: build/wannier90
	touch build/wannier90/make.inc
	${MAKE} lib \
	-C build/wannier90 \
	"F90=${FC}" \
	"FCOPTS=${FCFLAGS} ${FCFLAGS_BLAS} ${FCFLAGS_LAPACK}" \
	"LDOPTS=${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK}"
	mkdir -p build/install/lib
	cp build/wannier90/libwannier.a build/install/lib
build/lib/libxc.a: build/install/lib/libxc.a
	cp $< $@
build/lib/libxcf03.a: build/install/lib/libxcf03.a
	cp $< $@
build/install/lib/libxc.a build/install/lib/libxcf03.a &: build/libxc
	cd build/libxc && autoreconf -i
	cd build/libxc && \
	CC="${CC}" \
	FC="${FC}" \
	CFLAGS="${CFLAGS}" \
	FCFLAGS="${FCFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	./configure --disable-fhc
	${MAKE} -C build/libxc
	${MAKE} -C build/libxc install prefix="${CURDIR}/build/install"
build/lib/libbeef.a: build/install/lib/libbeef.a
	cp $< $@
build/install/lib/libbeef.a: build/libbeef
	cd build/libbeef && \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	./configure
	${MAKE} -C build/libbeef
	${MAKE} -C build/libbeef install prefix="${CURDIR}/build/install"
build/lib/libmctc-lib.a: build/install/lib/libmctc-lib.a
	cp $< $@
build/install/lib/libmctc-lib.a: build/mctc-lib
	cd build/mctc-lib && \
	CC="${CC}" \
	FC="${FC}" \
	CFLAGS="${CFLAGS}" \
	FFLAGS="${FCFLAGS}" \
	LDFLAGS="${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK}" \
	meson setup _build --prefix="${CURDIR}/build/install" \
	--wrap-mode=forcefallback \
	-Dopenmp=false \
	-Dlibdir=lib
	cd build/mctc-lib && meson compile -C _build
	cd build/mctc-lib && meson install -C _build
build/lib/libdftd4.a: build/install/lib/libdftd4.a
	cp $< $@
build/install/lib/libdftd4.a: build/dftd4 build/lib/libmctc-lib.a
	cd build/dftd4 && \
	CC="${CC}" \
	FC="${FC}" \
	CFLAGS="${CFLAGS}" \
	FFLAGS="${FCFLAGS}" \
	LDFLAGS="${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK}" \
	meson setup _build --prefix="${CURDIR}/build/install" \
	--wrap-mode=forcefallback \
	-Dopenmp=false \
	-Dlapack=custom \
	-Dlibdir=lib
	cd build/dftd4 && meson compile -C _build
	cd build/dftd4 && meson install -C _build
build/lib/libs-dftd3.a: build/install/lib/libs-dftd3.a
	cp $< $@
build/install/lib/libs-dftd3.a: build/simple-dftd3 build/lib/libmctc-lib.a
	cd build/simple-dftd3 && \
	CC="${CC}" \
	FC="${FC}" \
	CFLAGS="${CFLAGS}" \
	FFLAGS="${FCFLAGS}" \
	LDFLAGS="${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK}" \
	meson setup _build --prefix="${CURDIR}/build/install" \
	--wrap-mode=forcefallback \
	-Dopenmp=false \
	-Dblas=custom \
	-Dlibdir=lib
	cd build/simple-dftd3 && meson compile -C _build
	cd build/simple-dftd3 && meson install -C _build
build/lib/libelpa.a: build/install/lib/libelpa.a
	cp $< $@
build/install/lib/libelpa.a: build/elpa
	cd build/elpa && ./autogen.sh
	cd build/elpa && \
	CC="${MPICC}" \
	CXX="${MPICXX}" \
	FC="${MPIFC}" \
	CFLAGS="${CFLAGS} ${CFLAGS_BLAS} ${CFLAGS_LAPACK} ${CFLAGS_BLACS} ${CFLAGS_SCALAPACK}" \
	FCFLAGS="${FCFLAGS} ${FFLAGS_BLAS} ${FFLAGS_LAPACK} ${FFLAGS_BLACS} ${FFLAGS_SCALAPACK}" \
	LDFLAGS="${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK} ${LDFLAGS_BLACS} ${LDFLAGS_SCALAPACK}" \
	./configure
	${MAKE} -C build/elpa
	${MAKE} -C build/elpa install prefix="${CURDIR}/build/install"
build/lib/libmbd.a: build/install/lib/libmbd.a
	cp $< $@
build/install/lib/libmbd.a: build/libmbd
	echo "add_library(LAPACK::LAPACK INTERFACE IMPORTED)" > build/libmbd/cmake/FindLAPACK.cmake
	echo "set(LAPACK_FOUND TRUE)" >> build/libmbd/cmake/FindLAPACK.cmake
	CC="${CC}" \
	FC="${FC}" \
	CFLAGS="${CFLAGS}" \
	FFLAGS="${FCFLAGS} ${FCFLAGS_BLAS} ${FCFLAGS_LAPACK}" \
	LDFLAGS="${LDFLAGS} ${LDFLAGS_BLAS} ${LDFLAGS_LAPACK}" \
	cmake build/libmbd \
	-B build/libmbd/build \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_SCALAPACK_MPI=OFF \
	-DBUILD_SHARED_LIBS=OFF
	cmake --build build/libmbd/build
	cmake --install build/libmbd/build --prefix "${CURDIR}/build/install"
build/lib/libpspfft.a: build/install/lib/libpspfft.a
	cp $< $@
build/install/lib/libpspfft.a: build/pspfft
	echo "" > build/pspfft/Config/Makefile_Config
	${MAKE} -C build/pspfft/Build \
	"FORTRAN_COMPILE=${MPIFC} -c" \
	"FORTRAN_OPTIMIZE=${FCFLAGS}" \
	"INCLUDE_FFTW=${FCFLAGS_FFTW}"
	${MAKE} -C build/pspfft/Build install INSTALL="${CURDIR}/build/install"
build/lib/libdlmg.a: build/install/lib/libdlmg.a
	cp $< $@
build/install/lib/libdlmg.a: build/dl_mg_code_public
	echo "FC=${MPIFC}" > build/dl_mg_code_public/platforms/vaspenv.inc
	echo "FFLAGS=${FCFLAGS} -module \$$(OBJDIR) -I\$$(LIBDIR) -I\$$(OBJDIR) -DMPI" >> build/dl_mg_code_public/platforms/vaspenv.inc
	${MAKE} PLATFORM=vaspenv \
	-C build/dl_mg_code_public
	mkdir -p build/install/include
	mkdir -p build/install/lib
	cp build/dl_mg_code_public/lib/dl_mg.mod build/install/include
	cp build/dl_mg_code_public/lib/libdlmg.a build/install/lib

build/%: dependencies/% ./build
	cp -r $< build/

./build:
	mkdir -p build/include
	mkdir -p build/lib
	mkdir -p build/makefiles
	mkdir -p build/tools
	echo "\
	INCS  += \"-I${CURDIR}/build/include\"\n\
	FFLAGS+= ${FCFLAGS}\n\
	LINK  += ${LDFLAGS}\n\
	" > build/makefiles/base.mk
	ln -s $$(which ${AR}) build/tools/ar
	ln -s $$(which ${NM}) build/tools/nm
	ln -s $$(which ${RANLIB}) build/tools/ranlib

.PHONY: all clean vasp optionals hdf5 wannier90 libxc libbeef dftd4 simple-dftd3 elpa libmbd pspfft scpc
