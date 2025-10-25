#!/bin/bash

export SDKROOT=${CONDA_BUILD_SYSROOT}
unset CONDA_BUILD_SYSROOT

extra_pkgs=()

if [[ ! -d  $SRC_DIR/cf-compilers ]]; then
    if [[ "$build_platform" != "$target_platform" ]]; then
      # we need a compiler to target cross_target_platform.
      # when build_platform == target_platform, the compiler
      # just built can be used.
      # when build_platform != target_platform, the compiler
      # just built cannot be used, hence we need one that
      # can be used.
      extra_pkgs+=(
        "gcc_impl_${cross_target_platform}=${gcc_version}"
        "gxx_impl_${cross_target_platform}=${gcc_version}"
        "gfortran_impl_${cross_target_platform}=${gcc_version}"
      )
    fi
    if [[ "${cross_target_platform}" != "osx-"* ]]; then
      extra_pkgs+=(
        "binutils_impl_${cross_target_platform}=${binutils_version}"
        "${cross_target_stdlib}_${cross_target_platform}=${cross_target_stdlib_version}"
      )
    else
      extra_pkgs+=(
        "clang"
        "cctools_${cross_target_platform}"
        "ld64_${cross_target_platform}"
      )
    fi
    # Remove conda-forge/label/sysroot-with-crypt when GCC < 14 is dropped
    conda create -p $SRC_DIR/cf-compilers -c conda-forge/label/sysroot-with-crypt -c conda-forge --yes --quiet \
      "gcc_impl_${build_platform}" \
      "gxx_impl_${build_platform}" \
      "gfortran_impl_${build_platform}" \
      "gcc_impl_${target_platform}" \
      "gxx_impl_${target_platform}" \
      "gfortran_impl_${target_platform}" \
      "${c_stdlib}_${target_platform}=${c_stdlib_version}" \
      ${extra_pkgs[@]}
fi

export PATH=$SRC_DIR/cf-compilers/bin:$PATH
export BUILD_PREFIX=$SRC_DIR/cf-compilers

if [[ "$target_platform" == "win-"* && "${PREFIX}" != *Library ]]; then
    export PREFIX=${PREFIX}/Library
fi

source $RECIPE_DIR/get_cpu_arch.sh

if [[ "$cross_target_platform" == "osx-"* ]]; then
    ln -sf ${BUILD_PREFIX}/bin/llvm-cxxfilt ${BUILD_PREFIX}/bin/c++filt
fi

if [[ "$target_platform" == "win-64" ]]; then
  EXEEXT=".exe"
else
  EXEEXT=""
fi
SYSROOT_DIR=${PREFIX}/${TARGET}/sysroot
