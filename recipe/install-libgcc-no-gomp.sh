source ${RECIPE_DIR}/install-libgcc.sh

# remove and relink things
rm -f ${PREFIX}/lib/libgomp.so
rm -f ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so

# make the right links
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1} ${PREFIX}/lib/libgomp.so
ln -s ${PREFIX}/lib/libgomp.so ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so
