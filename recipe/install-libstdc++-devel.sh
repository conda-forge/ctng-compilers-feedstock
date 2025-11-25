#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
# export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${TARGET}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build

make -C $TARGET/libstdc++-v3/src prefix=${PREFIX} install
make -C $TARGET/libstdc++-v3/include prefix=${PREFIX} install
make -C $TARGET/libstdc++-v3/libsupc++ prefix=${PREFIX} install

mkdir -p ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}

if [[ "${HOST}" == "${TARGET}" ]]; then
    mv $PREFIX/lib/lib*.a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
    if [[ "${TARGET}" == *linux* ]]; then
        mv ${PREFIX}/lib/libstdc++.so* ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
    else
        rm ${PREFIX}/bin/libstdc++*.dll
    fi
else
    mv $PREFIX/${TARGET}/lib/lib*.a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
    if [[ "${TARGET}" == *linux* ]]; then
        mv ${PREFIX}/${TARGET}/lib/libstdc++.so* ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
    fi
fi

popd

