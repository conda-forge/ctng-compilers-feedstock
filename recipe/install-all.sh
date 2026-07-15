#!/bin/bash

set -eo pipefail

# Install the native runtime libraries first. Some of the existing runtime
# installers deliberately clean their destination before installing, so these
# must run before the compiler and development files are added to the shared
# staging prefix.
if [[ "${target_platform}" == "${cross_target_platform}" ]]; then
  export PKG_NAME=libgcc
  source "${RECIPE_DIR}/install-libgcc-no-gomp.sh"

  if [[ "${cross_target_cxx_stdlib}" == "libstdcxx" ]]; then
    export PKG_NAME=libstdcxx
    source "${RECIPE_DIR}/install-libstdc++.sh"
  fi

  if [[ "${cross_target_platform}" != win-* && "${cross_target_platform}" != osx-* ]]; then
    export PKG_NAME=libsanitizer
    source "${RECIPE_DIR}/install-libsanitizer.sh"
  fi

  if [[ "${cross_target_platform}" != osx-* ]]; then
    export PKG_NAME=libgomp
    source "${RECIPE_DIR}/install-libgomp.sh"
  fi

  export PKG_NAME="libgfortran${libgfortran_soname}"
  source "${RECIPE_DIR}/install-libgfortran.sh"
fi

# Development files are also produced for cross compilers.
export PKG_NAME="libgcc-devel_${cross_target_platform}"
source "${RECIPE_DIR}/install-libgcc-devel.sh"

if [[ "${cross_target_cxx_stdlib}" == "libstdcxx" ]]; then
  export PKG_NAME="libstdcxx-devel_${cross_target_platform}"
  source "${RECIPE_DIR}/install-libstdc++-devel.sh"
fi

# Install all compiler frontends into one staging prefix. The package outputs
# below select their files from this prefix instead of running one install
# script per output.
export PKG_NAME="gcc_impl_${cross_target_platform}"
source "${RECIPE_DIR}/install-gcc.sh"

export PKG_NAME="gxx_impl_${cross_target_platform}"
source "${RECIPE_DIR}/install-g++.sh"

export PKG_NAME="gfortran_impl_${cross_target_platform}"
source "${RECIPE_DIR}/install-gfortran.sh"

if [[ "${target_platform}" == "${cross_target_platform}" ]]; then
  if [[ "${cross_target_platform}" == linux-* ]]; then
    # (Re-)create the SONAME symlink packaged by _openmp_mutex. Use -f
    # because installing gcc_impl above already recreated it.
    mkdir -p "${PREFIX}/lib"
    ln -sf "libgomp.so.${libgomp_ver}" "${PREFIX}/lib/libgomp.so.${libgomp_ver:0:1}"
  fi

  export PKG_NAME=conda-gcc-specs
  source "${RECIPE_DIR}/install-conda-specs.sh"

  if [[ "${HOST}" == *mingw* ]]; then
    symlink_or_copy="cp"
  else
    symlink_or_copy="ln -sf"
  fi

  for PKG_NAME in gcc gxx gfortran; do
    export PKG_NAME
    case "${PKG_NAME}" in
      gcc)
        TOOLS="gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool"
        [[ "${HOST}" == *darwin* ]] || TOOLS="${TOOLS} cc cpp"
        ;;
      gxx)
        TOOLS="g++"
        [[ "${HOST}" == *darwin* ]] || TOOLS="${TOOLS} c++"
        ;;
      gfortran)
        TOOLS="gfortran"
        ;;
    esac

    for tool in ${TOOLS}; do
      ${symlink_or_copy} "${PREFIX}/bin/${TARGET}-${tool}${EXEEXT}" "${PREFIX}/bin/${tool}${EXEEXT}"
    done
  done
fi
