#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x

rm -f ${PREFIX}/lib/libgfortran* || true

if [[ "${TARGET}" == *mingw* ]]; then
  mkdir -p ${PREFIX}/bin/
  mkdir -p ${PREFIX}/lib/
  cp ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.dll ${PREFIX}/bin/
  cp ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran.dll.a ${PREFIX}/lib/
elif [[ "${TARGET}" == *linux* ]]; then
  mkdir -p ${PREFIX}/lib
  cp -f -P ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.so* ${PREFIX}/lib/
elif [[ "${TARGET}" == *darwin* ]]; then
  mkdir -p ${PREFIX}/lib
  cp -f -P ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.dylib ${PREFIX}/lib/
else
  echo "${TARGET} not handled"
  exit 1
fi

mkdir -p ${PREFIX}/share/licenses/libgfortran
# Install Runtime Library Exception
install -Dm644 $SRC_DIR/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/libgfortran/RUNTIME.LIBRARY.EXCEPTION
