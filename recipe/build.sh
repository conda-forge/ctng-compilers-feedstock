#!/bin/bash

set -ex

source ${RECIPE_DIR}/setup_compiler.sh

# ensure patch is applied
grep 'conda-forge:: allow' gcc/gcc.c*

GCC_CONFIGURE_OPTIONS=()

if [[ "$channel_targets" == *conda-forge* ]]; then
  GCC_CONFIGURE_OPTIONS+=(--with-pkgversion="conda-forge gcc ${gcc_version}-${PKG_BUILDNUM}")
  GCC_CONFIGURE_OPTIONS+=(--with-bugurl="https://github.com/conda-forge/ctng-compilers-feedstock/issues/new/choose")
fi

for tool in addr2line ar as c++filt cc c++ dsymutil fc gcc g++ gfortran ld nm objcopy objdump ranlib readelf size strings strip; do
  tool_upper=$(echo $tool | tr a-z-+ A-Z_X)
  if [[ "$tool" == "cc" ]]; then
     tool=gcc
  elif [[ "$tool" == "fc" ]]; then
     tool=gfortran
  elif [[ "$tool" == "c++" ]]; then
     tool=g++
  elif [[ "$tool" =~ ^(ar|nm|ranlib)$ && "${TARGET}" != *darwin* && -f $BUILD_PREFIX/bin/${TARGET}-gcc-${tool} ]]; then
     tool="gcc-${tool}"
  fi
  eval "export ${tool_upper}_FOR_BUILD=\$BUILD_PREFIX/bin/\$BUILD-\$tool"
  eval "export ${tool_upper}=\$BUILD_PREFIX/bin/\$HOST-\$tool"
  eval "export ${tool_upper}_FOR_TARGET=\$BUILD_PREFIX/bin/\$TARGET-\$tool"
done

if [[ "${TARGET}" == *mingw* ]]; then
  # do not expect ${prefix}/mingw symlink - this should be superceded by
  # 0005-Windows-Don-t-ignore-native-system-header-dir.patch .. but isn't!
  sed -i.bak 's#${prefix}/mingw/#${prefix}/${target}/sysroot/usr/#g' configure
  if [[ "$gcc_maj_ver" == "13" || "$gcc_maj_ver" == "14" ]]; then
    sed -i.bak "s#/mingw/#/usr/#g" gcc/config/i386/mingw32.h
  else
    sed -i.bak "s#/mingw/#/usr/#g" gcc/config/mingw/mingw32.h
  fi
else
  # prevent mingw patches from being archived in linux conda packages
  rm -rf ${RECIPE_DIR}/patches/mingw
fi

if [[ "${BUILD}" == *darwin* ]]; then
  find ./ -name 'configure' -type f -exec sed -i -e 's/tmp_nm \-B/tmp_nm/g' {} \;
fi

if [[ "${TARGET}" != *darwin* ]]; then
  # prevent macos patches from being archived in linux conda packages
  rm -rf ${RECIPE_DIR}/patches/macos
fi

# workaround a bug in gcc build files when using external binutils
# and build != host == target
export gcc_cv_objdump=$OBJDUMP_FOR_TARGET

ls $BUILD_PREFIX/bin/

./contrib/download_prerequisites

for f in isl mpfr mpc/build-aux; do
  cp $BUILD_PREFIX/share/gnuconfig/config.* $f/
done

set +x
# We want CONDA_PREFIX/usr/lib not CONDA_PREFIX/usr/lib64 and this
# is the only way. It is incompatible with multilib (obviously).
TINFO_FILES=$(find . -path "*/config/*/t-*")
for TINFO_FILE in ${TINFO_FILES}; do
  sed -i.bak 's#^\(MULTILIB_OSDIRNAMES.*\)\(lib64\)#\1lib#g' ${TINFO_FILE}
  rm -f ${TINFO_FILE}.bak
  sed -i.bak 's#^\(MULTILIB_OSDIRNAMES.*\)\(libx32\)#\1lib#g' ${TINFO_FILE}
  rm -f ${TINFO_FILE}.bak
done
set -x

# workaround for https://gcc.gnu.org/bugzilla//show_bug.cgi?id=80196
if [[ "$gcc_version" == "11."* && "$build_platform" != "$target_platform" ]]; then
  sed -i.bak 's@-I$glibcxx_srcdir/libsupc++@-I$glibcxx_srcdir/libsupc++ -nostdinc++@g' libstdc++-v3/configure
fi

mkdir -p build
cd build

# We need to explicitly set the gxx include dir because previously
# with ct-ng, native build was not considered native because
# BUILD=HOST=x86_64-build_unknown-linux-gnu and TARGET=x86_64-conda-linux-gnu
# Depending on native or not, the include dir changes. Setting it explictly
# goes back to the original way.
# See https://github.com/gcc-mirror/gcc/blob/16e2427f50c208dfe07d07f18009969502c25dc8/gcc/configure.ac#L218

if [[ "$TARGET" == *linux* ]]; then
  GCC_CONFIGURE_OPTIONS+=(--enable-libsanitizer)
  GCC_CONFIGURE_OPTIONS+=(--enable-default-pie)
  GCC_CONFIGURE_OPTIONS+=(--enable-threads=posix)
  GCC_CONFIGURE_OPTIONS+=(--enable-__cxa_atexit)
fi

if [[ "${TARGET}" == *darwin* ]]; then
  GCC_CONFIGURE_OPTIONS+=(--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk)
  GCC_CONFIGURE_OPTIONS+=(--with-build-sysroot=${SDKROOT})
  GCC_CONFIGURE_OPTIONS+=(--enable-darwin-at-rpath)
  export gcc_cv_ld64_version=955.13
else
  GCC_CONFIGURE_OPTIONS+=(--with-sysroot=${PREFIX}/${TARGET}/sysroot)
  GCC_CONFIGURE_OPTIONS+=(--with-build-sysroot=${BUILD_PREFIX}/${TARGET}/sysroot)
  GCC_CONFIGURE_OPTIONS+=(--enable-plugin)
fi

if [[ "${cross_target_cxx_stdlib}" == "libcxx" ]]; then
  GCC_CONFIGURE_OPTIONS+=(--disable-libstdcxx)
fi

if [[ ! ("${BUILD}" == "${HOST}" && "${HOST}" != "${TARGET}") && "${TARGET}" != *darwin* ]]; then
  GCC_CONFIGURE_OPTIONS+=(--enable-lto)
fi

../configure \
  --prefix="$PREFIX" \
  --with-slibdir="$PREFIX/lib" \
  --libdir="$PREFIX/lib" \
  --mandir="$PREFIX/man" \
  --build=$BUILD \
  --host=$HOST \
  --target=$TARGET \
  --enable-languages=c,c++,fortran,objc,obj-c++ \
  --enable-libgomp \
  --disable-libssp \
  --enable-libquadmath \
  --enable-libquadmath-support \
  --disable-nls \
  --disable-bootstrap \
  --disable-multilib \
  --enable-long-long \
  --without-zstd \
  --with-native-system-header-dir=/usr/include \
  --with-gxx-include-dir="${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/include/c++" \
  --with-gxx-libcxx-include-dir="${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/../../../../include/c++/v1" \
  "${GCC_CONFIGURE_OPTIONS[@]}"

make -j${CPU_COUNT} || (cat ${TARGET}/libgomp/config.log; false)
