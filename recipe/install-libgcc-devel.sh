#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x



# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
#export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${TARGET}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build

make -C ${TARGET}/libgcc prefix=${PREFIX} install

# Copy (not move): all outputs are selected from one shared staging prefix,
# so ${PREFIX}/lib/libgcc_s* has to stay in place for the libgcc output while
# the copies in ${PREFIX}/lib/gcc/TARGET/gcc_version go into this output
# (for cross-compilers the leftovers in ${PREFIX}/lib are simply not packaged).
if [[ "${TARGET}" == *linux* ]]; then
  cp -a ${PREFIX}/lib/libgcc_s.so* ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}
elif [[ "${TARGET}" == *darwin* ]]; then
  cp -a ${PREFIX}/lib/libgcc_s*.dylib ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}
else
  # import library, not static library
  mv ${PREFIX}/lib/libgcc_s.a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
  rm ${PREFIX}/lib/libgcc_s*.dll || true
fi
# This is in gcc_impl as it is gcc specific and clang has the same header
rm -rf ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/include/unwind.h

popd

