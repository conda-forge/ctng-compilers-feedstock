set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# we have to remove existing links/files so that the libgcc install works
rm -rf ${PREFIX}/lib/*
rm -rf ${PREFIX}/${CHOST}/sysroot/lib/*
rm -rf ${PREFIX}/share/*

# now run install of libgcc
# this reinstalls the wrong symlinks for openmp
source ${RECIPE_DIR}/install-libgcc.sh

# remove and relink things for openmp
rm -f ${PREFIX}/lib/libgomp.so
rm -f ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so
rm -f ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1}
rm -f ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver:0:1}
rm -f ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver}

# make the right links
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver} ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1}
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1} ${PREFIX}/lib/libgomp.so

ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver} ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver}
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1} ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver:0:1}
ln -s ${PREFIX}/lib/libgomp.so ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so

# debugging
echo "debug the links..."
ls -lah ${PREFIX}/lib/libgomp.so*
ls -lah ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so*
