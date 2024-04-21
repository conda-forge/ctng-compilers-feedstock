#!/bin/bash

source ${RECIPE_DIR}/get_cpu_arch.sh

if [[ "${PKG_NAME}" == "gcc" ]]; then
  for tool in cc cpp gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool; do
    ln -sf ${PREFIX}/bin/${CHOST}-${tool} ${PREFIX}/bin/${tool}
  done
elif [[ "${PKG_NAME}" == "gxx" ]]; then
  ln -sf ${PREFIX}/bin/${CHOST}-g++ ${PREFIX}/bin/g++
  ln -sf ${PREFIX}/bin/${CHOST}-c++ ${PREFIX}/bin/c++
elif [[ "${PKG_NAME}" == "gfortran" ]]; then
  ln -sf ${PREFIX}/bin/${CHOST}-gfortran ${PREFIX}/bin/gfortran
fi
