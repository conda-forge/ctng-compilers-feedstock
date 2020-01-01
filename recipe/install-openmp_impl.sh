set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib

ln -s ${PREFIX}/lib/libgomp.so.1.0.0 ${PREFIX}/lib/libgomp.so.1 
ln -s ${PREFIX}/lib/libgomp.so.1 ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.1
