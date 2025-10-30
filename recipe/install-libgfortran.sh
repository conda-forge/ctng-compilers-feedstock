#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x

rm -f ${PREFIX}/lib/libgfortran* || true

if [[ "${TARGET}" == *mingw* ]]; then
  mkdir -p ${PREFIX}/bin/
  cp ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.dll ${PREFIX}/bin/
elif [[ "${TARGET}" == *linux* ]]; then
  mkdir -p ${PREFIX}/lib
  cp -f --no-dereference ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.so* ${PREFIX}/lib/
else
  mkdir -p ${PREFIX}/lib
  cp -f --no-dereference ${SRC_DIR}/build/${TARGET}/libgfortran/.libs/libgfortran*.dylib* ${PREFIX}/lib/
fi

# Install Runtime Library Exception
install -Dm644 $SRC_DIR/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/libgfortran/RUNTIME.LIBRARY.EXCEPTION
