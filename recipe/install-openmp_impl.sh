set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# TODO remove for conda build > 3.18.11
# hack for conda build bug on symlinks
mkdir -p $PREFIX/bin
for action in post-link pre-unlink; do
    sed -i "1iCHOST=${CHOST}" $RECIPE_DIR/openmp_impl-${action}.sh
    cp $RECIPE_DIR/openmp_impl-${action}.sh $PREFIX/bin/.openmp_impl-${action}.sh
done
# end of hack

# actual script for later
# CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)
#
# mkdir -p ${PREFIX}/lib
# mkdir -p ${PREFIX}/${CHOST}/sysroot/lib
#
# ln -s ${PREFIX}/lib/libgomp.so.1.0.0 ${PREFIX}/lib/libgomp.so.1
# ln -s ${PREFIX}/lib/libgomp.so.1 ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so.1
