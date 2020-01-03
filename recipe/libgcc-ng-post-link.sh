

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib

if [ ! -f "${PREFIX}/lib/libgomp.so" ] && [ ! -f "${PREFIX}/${CHOST}/sysroot/lib/libgomp.so" ]; then
    ln -s ${PREFIX}/lib/libgomp.so.1 ${PREFIX}/lib/libgomp.so
    ln -s ${PREFIX}/lib/libgomp.so ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so
else
    echo "${PKG_NAME}-${PKG_VERSION}: symlinks for openmp already exist so they were not made!" >> $PREFIX/.messages.txt
fi
