#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x



# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
#export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${TARGET}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build

  make -C ${TARGET}/libstdc++-v3/src prefix=${PREFIX} install-toolexeclibLTLIBRARIES
  make -C ${TARGET}/libstdc++-v3/po prefix=${PREFIX} install

popd

mkdir -p ${PREFIX}/lib

# no static libs
find ${PREFIX}/lib -name "*\.a" ! -name "*\.dll\.a" -exec rm -rf {} \;
# no libtool files
find ${PREFIX}/lib -name "*\.la" -exec rm -rf {} \;

mkdir -p ${PREFIX}/share/licenses/libstdc++
# Install Runtime Library Exception
install -Dm644 ${SRC_DIR}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/libstdc++/RUNTIME.LIBRARY.EXCEPTION
