#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh

if [[ "$target_platform" == "win-"* ]]; then
  symlink="cp"
else
  symlink="ln -sf"
fi

if [[ "${PKG_NAME}" == "gcc" ]]; then
  for tool in cc cpp gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool; do
    $symlink ${PREFIX}/bin/${triplet}-${tool} ${PREFIX}/bin/${tool}
  done
elif [[ "${PKG_NAME}" == "gxx" ]]; then
  $symlink ${PREFIX}/bin/${triplet}-g++ ${PREFIX}/bin/g++
  $symlink ${PREFIX}/bin/${triplet}-c++ ${PREFIX}/bin/c++
elif [[ "${PKG_NAME}" == "gfortran" ]]; then
  $symlink ${PREFIX}/bin/${triplet}-gfortran ${PREFIX}/bin/gfortran
fi
