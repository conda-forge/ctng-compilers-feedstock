set -e -x

export CHOST="${ctng_cpu_arch}-${ctng_vendor}-linux-gnu"

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
# export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build

make -C $CHOST/libstdc++-v3/src prefix=${PREFIX}/${CHOST} install
make -C $CHOST/libstdc++-v3/include prefix=${PREFIX}/${CHOST} install
make -C $CHOST/libstdc++-v3/libsupc++ prefix=${PREFIX}/${CHOST} install

rm -rf ${PREFIX}/${CHOST}/lib/libstdc++.so*

popd

