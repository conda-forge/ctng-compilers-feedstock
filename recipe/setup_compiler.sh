#!/bin/bash

source $RECIPE_DIR/get_cpu_arch.sh

export SDKROOT=${CONDA_BUILD_SYSROOT}
unset CONDA_BUILD_SYSROOT

extra_pkgs=()

export CF_PREFIX=$SRC_DIR/cf-compilers

if [[ ! -d ${SRC_DIR}/cf-compilers ]]; then
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
    if [[ "${build_platform}" == "osx-"* ]]; then
      extra_pkgs+=(
        "make"
      )
    fi
    # Remove conda-forge/label/sysroot-with-crypt when GCC < 14 is dropped
    conda create -p ${CF_PREFIX} -c conda-forge/label/gcc-experimental -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local --yes --quiet \
      "gcc_impl_${build_platform}" \
      "gxx_impl_${build_platform}" \
      "gfortran_impl_${build_platform}" \
      "gcc_impl_${target_platform}" \
      "gxx_impl_${target_platform}" \
      "gfortran_impl_${target_platform}" \
      "${c_stdlib}_${target_platform}=${c_stdlib_version}" \
      gnuconfig \
      ${extra_pkgs[@]}

    if [[ "${TARGET}" == *darwin* ]]; then
      CONDA_OVERRIDE_OSX=15.5 CONDA_SUBDIR="${cross_target_platform}" conda create -p $SRC_DIR/cf-compilers-target -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local --yes --quiet libcxx-devel
      mkdir -p ${CF_PREFIX}/${TARGET}/lib
      ln -sf $SRC_DIR/cf-compilers-target/lib/libc++* ${CF_PREFIX}/${TARGET}/lib

    fi
    if [[ "${HOST}" == *darwin* && "${HOST}" != "${TARGET}" ]]; then
      CONDA_OVERRIDE_OSX=15.5 CONDA_SUBDIR="${target_platform}" conda create -p $SRC_DIR/cf-compilers-host -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local --yes --quiet libcxx-devel
      mkdir -p ${CF_PREFIX}/${HOST}/lib
      ln -sf $SRC_DIR/cf-compilers-host/lib/libc++* ${CF_PREFIX}/${HOST}/lib
    fi
fi

if [[ "${BUILD_PREFIX}" != "${PREFIX}" ]]; then
  ln -sf ${CF_PREFIX}/${TARGET} ${BUILD_PREFIX}/${TARGET} || true
  ln -sf ${CF_PREFIX}/bin ${BUILD_PREFIX}/bin || true
  ln -sf ${CF_PREFIX}/share ${BUILD_PREFIX}/share || true
fi

export PATH=$SRC_DIR/cf-compilers/bin:$PATH

if [[ "$target_platform" == "win-"* && "${PREFIX}" != *Library ]]; then
    export PREFIX=${PREFIX}/Library
fi

if [[ "$target_platform" == "win-64" ]]; then
  EXEEXT=".exe"
else
  EXEEXT=""
fi
SYSROOT_DIR=${PREFIX}/${TARGET}/sysroot

if [[ "$target_platform" == "osx-"* ]]; then
  STRIP_ARGS=""
else
  STRIP_ARGS="--strip-all"
fi
