

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib

if [ ! -f "$PREFIX/lib/libgomp.so.1" ] && [ ! -f "${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.1" ]; then
    ln -s ${PREFIX}/lib/libgomp.so.1.0.0 ${PREFIX}/lib/libgomp.so.1
    ln -s ${PREFIX}/lib/libgomp.so.1 ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.1
else
    echo "${PKG_NAME}-${PKG_VERSION}: symlinks for openmp already exist so they were not made!" >> $PREFIX/.messages.txt
fi
