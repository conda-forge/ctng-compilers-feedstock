#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x


_libdir=libexec/gcc/${TARGET}/${PKG_VERSION}

mkdir -p $PREFIX/lib/gcc/${TARGET}/${gcc_version}/finclude
mkdir -p $PREFIX/lib/gcc/${TARGET}/${gcc_version}/include

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
#export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${TARGET}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build

# adapted from Arch install script from https://github.com/archlinuxarm/PKGBUILDs/blob/master/core/gcc/PKGBUILD
# We cannot make install since .la files are not relocatable so libtool deliberately prevents it:
# libtool: install: error: cannot install `libgfortran.la' to a directory not ending in ${SRC_DIR}/work/gcc_built/${TARGET}/lib/../lib
make -C ${TARGET}/libgfortran prefix=${PREFIX} all-multi libgfortran.spec ieee_arithmetic.mod ieee_exceptions.mod ieee_features.mod config.h
make -C gcc prefix=${PREFIX} fortran.install-{common,man,info}

# How it used to be:
# install -Dm755 gcc/f951 ${PREFIX}/${_libdir}/f951
for file in f951; do
  if [[ -f gcc/${file}${EXEEXT} ]]; then
    install -c gcc/${file}${EXEEXT} ${PREFIX}/${_libdir}/${file}${EXEEXT}
  fi
done

cp ${TARGET}/libgfortran/libgfortran.spec ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/

pushd ${PREFIX}/bin
  if [[ "${HOST}" != *mingw* ]]; then
    ln -sf ${TARGET}-gfortran${EXEEXT} ${TARGET}-f95${EXEEXT}
  else
    cp ${TARGET}-gfortran${EXEEXT} ${TARGET}-f95${EXEEXT}
  fi
popd

make install DESTDIR=$SRC_DIR/build-finclude
install -Dm644 $SRC_DIR/build-finclude/$PREFIX/lib/gcc/${TARGET}/${gcc_version}/finclude/* $PREFIX/lib/gcc/${TARGET}/${gcc_version}/finclude/
install -Dm644 $SRC_DIR/build-finclude/$PREFIX/lib/gcc/${TARGET}/${gcc_version}/include/*.h $PREFIX/lib/gcc/${TARGET}/${gcc_version}/include/

mkdir -p ${PREFIX}/share/licenses/gcc-fortran
# Install Runtime Library Exception
install -Dm644 $SRC_DIR/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc-fortran/RUNTIME.LIBRARY.EXCEPTION

if [[ "${HOST}" == "${TARGET}" ]]; then
  if [[ ${TARGET} == *linux* ]]; then
    ln -sf ${PREFIX}/lib/libgfortran.so ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/libgfortran.so
  elif [[ ${TARGET} == *darwin* ]]; then
    ln -sf ${PREFIX}/lib/libgfortran.dylib ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/libgfortran.dylib
  fi
else
  if [[ ${TARGET} == *linux* ]]; then
    cp -f -P ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.so* ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
  elif [[ ${TARGET} == *darwin* ]]; then
    cp -f -P ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.dylib ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
  fi
fi
cp -f -P ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran.*a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/

set +x
# Strip executables, we may want to install to a different prefix
# and strip in there so that we do not change files that are not
# part of this package.
pushd ${PREFIX}
  _files=$(find bin libexec -type f -not -name '*.dll')
  for _file in ${_files}; do
    _type="$( file "${_file}" | cut -d ' ' -f 2- )"
    case "${_type}" in
      *script*executable*)
      ;;
      *executable*)
        ${BUILD_PREFIX}/bin/${HOST}-strip ${STRIP_ARGS} -v "${_file}" || :
      ;;
    esac
  done
popd

if [[ -f ${PREFIX}/lib/libgomp.spec ]]; then
  mv ${PREFIX}/lib/libgomp.spec ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/libgomp.spec
fi

rm -f ${PREFIX}/share/info/dir

source ${RECIPE_DIR}/make_tool_links.sh
