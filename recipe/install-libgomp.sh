source ${RECIPE_DIR}/install-libgcc.sh

# stash what we need and rm -rf the rest
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
cp ${PREFIX}/lib/libgomp.so.${libgomp_ver} ${tmp_dir}/libgomp.so.${libgomp_ver}
rm -rf ${PREFIX}/*

# copy back and make the right links
mkdir -p ${PREFIX}/lib
cp ${tmp_dir}/libgomp.so.${libgomp_ver} ${PREFIX}/lib/libgomp.so.${libgomp_ver}
ln -s ${PREFIX}/lib/libgomp.so.${libgomp_ver} ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.${libgomp_ver}

# Install Runtime Library Exception
install -Dm644 ${SRC_DIR}/.build/src/gcc-${ctng_gcc}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION.gomp_copy

# remove the copy in libgcc
rm -f ${PREFIX}/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION
