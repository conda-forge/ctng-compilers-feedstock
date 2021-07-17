#!/bin/bash

set -e

get_cpu_arch() {
  local CPU_ARCH
  if [[ "$1" == "linux-64" ]]; then
    CPU_ARCH="x86_64"
  elif [[ "$1" == "linux-ppc64le" ]]; then
    CPU_ARCH="powerpc64le"
  elif [[ "$1" == "linux-aarch64" ]]; then
    CPU_ARCH="aarch64"
  elif [[ "$1" == "linux-s390x" ]]; then
    CPU_ARCH="s390x"
  else
    echo "Unknown architecture"
    exit 1
  fi
  echo $CPU_ARCH
}

export BUILD="$(get_cpu_arch $build_platform)-${ctng_vendor}-linux-gnu"
export HOST="$(get_cpu_arch $target_platform)-${ctng_vendor}-linux-gnu"
export TARGET="$(get_cpu_arch $ctng_target_platform)-${ctng_vendor}-linux-gnu"

if [[ ! -f $BUILD_PREFIX/bin/$BUILD-gcc ]]; then
  for tool in addr2line ar as c++filt gcc g++ ld nm objcopy objdump ranlib readelf size strings strip; do
    ln -s $(which $tool) $BUILD_PREFIX/bin/$BUILD-$tool
  done
fi

ls $BUILD_PREFIX/bin/

export CC_FOR_BUILD=$BUILD_PREFIX/bin/$BUILD-gcc
export CXX_FOR_BUILD=$BUILD_PREFIX/bin/$BUILD-g++

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

# We need to explicitly set the gxx include dir because previously
# with ct-ng, native build was not considered native because
# BUILD=HOST=x86_64-build_unknown-linux-gnu and TARGET=x86_64-conda-linux-gnu
# Depending on native or not, the include dir changes. Setting it explictly
# goes back to the original way.
# See https://github.com/gcc-mirror/gcc/blob/16e2427f50c208dfe07d07f18009969502c25dc8/gcc/configure.ac#L218

../configure \
  --prefix="$PREFIX" \
  --with-slibdir="$PREFIX/lib" \
  --libdir="$PREFIX/lib" \
  --build=$BUILD \
  --host=$HOST \
  --target=$TARGET \
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
  --with-sysroot=${PREFIX}/${TARGET}/sysroot \
  --with-build-sysroot=${PREFIX}/${TARGET}/sysroot \
  --with-gxx-include-dir="${PREFIX}/${TARGET}/include/c++/${ctng_gcc}"

make -j${CPU_COUNT}

#exit 1
