#!/bin/bash

set -e

#for file in ./crosstool_ng/packages/gcc/$PKG_VERSION/*.patch; do
#  patch -p1 < $file;
#done

export HOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"

build_binutils () {
  ../configure \
  --prefix="$1" \
  --target=$HOST \
  --enable-ld=default \
  --enable-gold=yes \
  --enable-plugins \
  --disable-multilib \
  --disable-sim \
  --disable-gdb \
  --disable-nls \
  --enable-default-pie \
  --with-sysroot=$PREFIX/$HOST/sysroot \
  --with-build-sysroot=$PREFIX/$HOST/sysroot

  make -j${CPU_COUNT}
}


#pushd binutils-src
#  for file in ../crosstool_ng/packages/binutils/${ctng_binutils}/*.patch; do
#    patch -p1 < $file;
#  done
#  mkdir -p  build
#  pushd build
#    build_binutils $BUILD_PREFIX
#    make install
#    build_binutils $PREFIX
#  popd
#popd

for f in addr2line ar as c++filt dwp elfedit gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf size strings strip; do
    ln -s $BUILD_PREFIX/bin/${ctng_cpu_arch}-conda-linux-gnu-$f $BUILD_PREFIX/bin/$f
    #ln -s $BUILD_PREFIX/bin/${ctng_cpu_arch}-conda_cos6-linux-gnu-$f $BUILD_PREFIX/bin/$f
    #ln -s $BUILD_PREFIX/bin/${ctng_cpu_arch}-conda_cos6-linux-gnu-$f $BUILD_PREFIX/bin/$HOST-$f
done

./contrib/download_prerequisites

# We want CONDA_PREFIX/usr/lib not CONDA_PREFIX/usr/lib64 and this
# is the only way. It is incompatible with multilib (obviously).
TINFO_FILES=$(find . -path "*/config/*/t-*")
for TINFO_FILE in ${TINFO_FILES}; do
  echo TINFO_FILE ${TINFO_FILE}
  sed -i.bak 's#^\(MULTILIB_OSDIRNAMES.*\)\(lib64\)#\1lib#g' ${TINFO_FILE}
  rm -f ${TINFO_FILE}.bak
  sed -i.bak 's#^\(MULTILIB_OSDIRNAMES.*\)\(libx32\)#\1lib#g' ${TINFO_FILE}
  rm -f ${TINFO_FILE}.bak
done

mkdir build
cd build

export HOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"

../configure \
  --prefix="$PREFIX" \
  --with-slibdir="$PREFIX/lib" \
  --libdir="$PREFIX/lib" \
  --build=$HOST \
  --host=$HOST \
  --target=$HOST \
  --enable-default-pie \
  --enable-languages=c,c++,fortran,objc,obj-c++ \
  --enable-__cxa_atexit \
  --disable-libmudflap \
  --enable-libgomp \
  --disable-libssp \
  --enable-libquadmath \
  --enable-libquadmath-support \
  --enable-libsanitizer \
  --enable-lto \
  --enable-threads=posix \
  --enable-target-optspace \
  --enable-plugin \
  --enable-gold \
  --disable-nls \
  --disable-bootstrap \
  --disable-multilib \
  --enable-long-long \
  --enable-default-pie \
  --with-sysroot=$PREFIX/$HOST/sysroot \
  --with-build-sysroot=$PREFIX/$HOST/sysroot

make -j${CPU_COUNT}

#exit 1
