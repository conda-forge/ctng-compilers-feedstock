#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x



# we have to remove existing links/files so that the libgcc install works
rm -rf ${PREFIX}/lib/*
rm -rf ${PREFIX}/share/*
rm -f ${PREFIX}/${TARGET}/lib/libgomp*

# now run install of libgcc
# this reinstalls the wrong symlinks for openmp
source ${RECIPE_DIR}/install-libgcc.sh

# remove and relink things for openmp
rm -f ${PREFIX}/lib/libgomp.so
rm -f ${PREFIX}/${TARGET}/lib/libgomp.so
rm -f ${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1}
rm -f ${PREFIX}/${TARGET}/lib/libgomp.so.${libgomp_ver:0:1}
rm -f ${PREFIX}/${TARGET}/lib/libgomp.so.${libgomp_ver}
rm -f ${PREFIX}/lib/libgomp.dylib
rm -f ${PREFIX}/${TARGET}/lib/libgomp.dylib
rm -f ${PREFIX}/lib/libgomp.${libgomp_ver:0:1}.dylib
rm -f ${PREFIX}/${TARGET}/lib/libgomp.${libgomp_ver:0:1}.dylib
rm -f ${PREFIX}/${TARGET}/lib/libgomp.${libgomp_ver}.dylib

# (re)make the right links
# note that this code is remaking more links than the ones we want in this
# package but that is ok
pushd ${PREFIX}/lib
  if [[ "${TARGET}" == *linux* ]]; then
    ln -s libgomp.so.${libgomp_ver} libgomp.so.${libgomp_ver:0:1}
  fi
popd
