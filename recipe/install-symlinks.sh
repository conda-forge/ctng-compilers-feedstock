#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh

if [[ "${HOST}" == *mingw* ]]; then
  symlink_or_copy="cp"
else
  symlink_or_copy="ln -sf"
fi

TOOLS=""
if [[ "${PKG_NAME}" == "gcc" ]]; then
  TOOLS="gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool"
  if [[ "${HOST}" != *darwin* ]]; then
    TOOLS="${TOOLS} cc cpp"
  fi
elif [[ "${PKG_NAME}" == "gxx" ]]; then
  TOOLS="g++"
  if [[ "${HOST}" != *darwin* ]]; then
    TOOLS="${TOOLS} c++"
  fi
elif [[ "${PKG_NAME}" == "gfortran" ]]; then
  TOOLS="gfortran"
fi

for tool in ${TOOLS}; do
  $symlink_or_copy ${PREFIX}/bin/${TARGET}-${tool}${EXEEXT} ${PREFIX}/bin/${tool}${EXEEXT}
done
