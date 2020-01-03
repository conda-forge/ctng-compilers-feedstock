

if [ "${PREFIX}/lib/libgomp.so" -ef "$PREFIX/lib/libgomp.so.1" ]; then
    # remove the file if it is a link
    rm $PREFIX/lib/libgomp.so
else
    echo "${PKG_NAME}-${PKG_VERSION}: \$PREFIX/lib/libgomp.so is not a symlink so it was not removed!" >> $PREFIX/.messages.txt
fi

if [ "${PREFIX}/${CHOST}/sysroot/lib/libgomp.so" -ef "${PREFIX}/lib/libgomp.so" ]; then
    # remove the file if it is a link
    rm ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so
else
    echo "${PKG_NAME}-${PKG_VERSION}: \${PREFIX}/${CHOST}/sysroot/lib/libgomp.so \
is not a symlink so it was not removed!" >> $PREFIX/.messages.txt
fi
