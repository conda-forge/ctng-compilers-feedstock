set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# we are using the centos CDTs instead
# we need this symlink
ln -s "${PREFIX}/${ctng_cpu_arch}-conda-linux-gnu" ${PREFIX}/${CHOST}
