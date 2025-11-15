#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh

if [[ "${HOST}" == *mingw* ]]; then
  symlink_or_copy="cp"
else
  symlink_or_copy="ln -sf"
fi

if [[ "${PKG_NAME}" == "gcc" ]]; then
  for tool in cc cpp gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool; do
    $symlink_or_copy ${PREFIX}/bin/${TARGET}-${tool}${EXEEXT} ${PREFIX}/bin/${tool}${EXEEXT}
  done
elif [[ "${PKG_NAME}" == "gxx" ]]; then
  $symlink_or_copy ${PREFIX}/bin/${TARGET}-g++${EXEEXT} ${PREFIX}/bin/g++${EXEEXT}
  $symlink_or_copy ${PREFIX}/bin/${TARGET}-c++${EXEEXT} ${PREFIX}/bin/c++${EXEEXT}
elif [[ "${PKG_NAME}" == "gfortran" ]]; then
  $symlink_or_copy ${PREFIX}/bin/${TARGET}-gfortran${EXEEXT} ${PREFIX}/bin/gfortran${EXEEXT}
fi
