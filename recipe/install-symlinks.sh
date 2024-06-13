#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh

if [[ "$target_platform" == "win-"* ]]; then
  symlink_or_copy="cp"
else
  symlink_or_copy="ln -sf"
fi

if [[ "${PKG_NAME}" == "gcc" ]]; then
  for tool in cc cpp gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool; do
    $symlink_or_copy ${PREFIX}/bin/${triplet}-${tool} ${PREFIX}/bin/${tool}
  done
elif [[ "${PKG_NAME}" == "gxx" ]]; then
  $symlink_or_copy ${PREFIX}/bin/${triplet}-g++ ${PREFIX}/bin/g++
  $symlink_or_copy ${PREFIX}/bin/${triplet}-c++ ${PREFIX}/bin/c++
elif [[ "${PKG_NAME}" == "gfortran" ]]; then
  $symlink_or_copy ${PREFIX}/bin/${triplet}-gfortran ${PREFIX}/bin/gfortran
fi
