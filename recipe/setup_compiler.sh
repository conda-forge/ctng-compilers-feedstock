#!/bin/bash

if [[ ! -d  $SRC_DIR/cf-compilers ]]; then
    conda create -p $SRC_DIR/cf-compilers -c conda-forge/label/sysroot-with-crypt -c conda-forge --yes --quiet \
      "binutils_impl_${build_platform}" \
      "gcc_impl_${build_platform}" \
      "gxx_impl_${build_platform}" \
      "gfortran_impl_${build_platform}" \
      "binutils_impl_${target_platform}=${binutils_version}" \
      "gcc_impl_${target_platform}" \
      "gxx_impl_${target_platform}" \
      "gfortran_impl_${target_platform}" \
      "${c_stdlib}_${target_platform}=${c_stdlib_version}"
fi

export PATH=$SRC_DIR/cf-compilers/bin:$PATH
export BUILD_PREFIX=$SRC_DIR/cf-compilers
