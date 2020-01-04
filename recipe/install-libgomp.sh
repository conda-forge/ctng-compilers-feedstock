set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/.build/${CHOST}/build/build-cc-gcc-final/
  # here we install to dummy temp prefix and then pull out only the lib we need
  mkdir -p ${PREFIX}/gomp_test_prefix
  mkdir -p ${PREFIX}/gomp_test_prefix/${CHOST}/sysroot/lib || true

  for lib in libgomp; do
    if [[ -d ${CHOST}/${lib} ]]; then
      make -C ${CHOST}/${lib} prefix=${PREFIX}/gomp_test_prefix install-toolexeclibLTLIBRARIES
      make -C ${CHOST}/${lib} prefix=${PREFIX}/gomp_test_prefix install-nodist_fincludeHEADERS || true
    fi
  done

  for lib in libgomp; do
    if [[ -d ${CHOST}/${lib} ]]; then
      make -C ${CHOST}/${lib} prefix=${PREFIX}/gomp_test_prefix install-info
    fi
  done

popd

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib
cp ${PREFIX}/gomp_test_prefix/${CHOST}/lib/libgomp.so.1.0.0 ${PREFIX}/lib/libgomp.so.1.0.0
ln -s ${PREFIX}/lib/libgomp.so.1.0.0 ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.1.0.0

# remove the dummy prefix
rm -rf ${PREFIX}/gomp_test_prefix

# no static libs
find ${PREFIX}/lib -name "*\.a" -exec rm -rf {} \;
# no libtool files
find ${PREFIX}/lib -name "*\.la" -exec rm -rf {} \;
# clean up empty folder
rm -rf ${PREFIX}/lib/gcc

# Install Runtime Library Exception
install -Dm644 ${SRC_DIR}/.build/src/gcc-${ctng_gcc}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION.gomp_copy
