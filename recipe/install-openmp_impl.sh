set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib

ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver} ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1}
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1} ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver:0:1}
