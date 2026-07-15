#!/bin/bash

get_cpu_arch() {
  local CPU_ARCH
  if [[ "$1" == *"-64" ]]; then
    CPU_ARCH="x86_64"
  elif [[ "$1" == *"-ppc64le" ]]; then
    CPU_ARCH="powerpc64le"
  elif [[ "$1" == *"-aarch64" ]]; then
    CPU_ARCH="aarch64"
  elif [[ "$1" == *"-s390x" ]]; then
    CPU_ARCH="s390x"
  elif [[ "$1" == *"-riscv64" ]]; then
    CPU_ARCH="riscv64"
  else
    echo "Unknown architecture"
    exit 1
  fi
  echo $CPU_ARCH
}

get_triplet() {
  if [[ "$1" == linux-* ]]; then
    echo "$(get_cpu_arch $1)-conda-linux-gnu"
  elif [[ "$1" == osx-64 ]]; then
    echo "x86_64-apple-darwin13.4.0"
  elif [[ "$1" == osx-arm64 ]]; then
    echo "arm64-apple-darwin20.0.0"
  elif [[ "$1" == win-64 ]]; then
    echo "x86_64-w64-mingw32"
  else
    echo "unknown platform"
    exit 1
  fi
}

export BUILD="$(get_triplet $build_platform)"
export HOST="$(get_triplet $target_platform)"
export TARGET_REF="$(get_triplet $cross_target_platform)"

if [[ "${TARGET}" != "${TARGET_REF}" ]]; then
  echo "TARGET: ${TARGET} does not match expected ${TARGET_REF}"
  exit 1
fi

export SDKROOT=${CONDA_BUILD_SYSROOT}
unset CONDA_BUILD_SYSROOT

# rattler-build exports PYTHON pointing into the host env, which contains no
# python; isl's configure hard-errors ("Python interpreter is too old") when
# $PYTHON is set but cannot be executed. conda-build never set it here.
unset PYTHON

extra_pkgs=()

# package downloads from conda.anaconda.org time out intermittently on the
# CI runners ("HTTP errors are often intermittent, and a simple retry will
# get you on your way"); retry the environment creation, removing the
# partially created prefix in between
conda_create_with_retry() {
  local prefix=$1 attempt
  shift
  for attempt in 1 2 3; do
    if conda create -p "${prefix}" --yes --quiet "$@"; then
      return 0
    fi
    rm -rf "${prefix}"
    echo "conda create -p ${prefix} failed (attempt ${attempt}), retrying" >&2
    sleep $((attempt * 20))
  done
  return 1
}

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
        "clangxx"
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
    conda_create_with_retry ${CF_PREFIX} -c conda-forge/label/gcc-experimental -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local \
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
      (export CONDA_OVERRIDE_OSX=15.5 CONDA_SUBDIR="${cross_target_platform}"; conda_create_with_retry $SRC_DIR/cf-compilers-target -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local libcxx-devel)
      mkdir -p ${CF_PREFIX}/${TARGET}/lib
      ln -sf $SRC_DIR/cf-compilers-target/lib/libc++* ${CF_PREFIX}/${TARGET}/lib

    fi
    if [[ "${HOST}" == *darwin* && "${HOST}" != "${TARGET}" ]]; then
      (export CONDA_OVERRIDE_OSX=15.5 CONDA_SUBDIR="${target_platform}"; conda_create_with_retry $SRC_DIR/cf-compilers-host -c conda-forge/label/sysroot-with-crypt -c conda-forge --use-local libcxx-devel)
      mkdir -p ${CF_PREFIX}/${HOST}/lib
      ln -sf $SRC_DIR/cf-compilers-host/lib/libc++* ${CF_PREFIX}/${HOST}/lib
    fi
    if [[ "${TARGET}" == *darwin* && ! -f "${CF_PREFIX}/bin/${TARGET}-clang" ]]; then
      ln -sf "${CF_PREFIX}/bin/clang" "${CF_PREFIX}/bin/${TARGET}-clang"
    fi
    if [[ "${TARGET}" == *darwin* && ! -f "${CF_PREFIX}/bin/${TARGET}-clang++" ]]; then
      ln -sf "${CF_PREFIX}/bin/${TARGET}-clang" "${CF_PREFIX}/bin/${TARGET}-clang++"
    fi
    if [[ "${HOST}" == *darwin* && ! -f "${CF_PREFIX}/bin/${HOST}-clang" ]]; then
      ln -sf "${CF_PREFIX}/bin/clang" "${CF_PREFIX}/bin/${HOST}-clang"
    fi
    if [[ "${HOST}" == *darwin* && ! -f "${CF_PREFIX}/bin/${HOST}-clang++" ]]; then
      ln -sf "${CF_PREFIX}/bin/${HOST}-clang" "${CF_PREFIX}/bin/${HOST}-clang++"
    fi
    if [[ "${BUILD}" == *darwin* && ! -f "${CF_PREFIX}/bin/${BUILD}-clang" ]]; then
      ln -sf "${CF_PREFIX}/bin/clang" "${CF_PREFIX}/bin/${BUILD}-clang"
    fi
    if [[ "${BUILD}" == *darwin* && ! -f "${CF_PREFIX}/bin/${BUILD}-clang++" ]]; then
      ln -sf "${CF_PREFIX}/bin/${BUILD}-clang" "${CF_PREFIX}/bin/${BUILD}-clang++"
    fi
fi

if [[ "${BUILD_PREFIX}" != "${PREFIX}" ]]; then
  # The build environment is not empty (it provides conda, whose
  # dependencies ship e.g. bin/, share/ and ld_impl's ${TARGET}/bin), so
  # these directories may already exist. Merge the cf-compilers tree into
  # it by symlinking entries, descending into existing real directories:
  # a plain `ln -sf` of a whole directory silently nests the link inside
  # an existing directory (share/share) and hides gnuconfig, the sysroot
  # and the cross tools from the build.
  merge_link_entries() {
    local src=$1 dst=$2 entry base
    mkdir -p "$dst"
    for entry in "$src"/*; do
      [ -e "$entry" ] || continue
      base=$(basename "$entry")
      if [ -d "$dst/$base" ] && [ ! -L "$dst/$base" ]; then
        merge_link_entries "$entry" "$dst/$base"
      else
        ln -sfn "$entry" "$dst/$base"
      fi
    done
  }
  merge_link_entries "${CF_PREFIX}/${TARGET}" "${BUILD_PREFIX}/${TARGET}"
  merge_link_entries "${CF_PREFIX}/bin" "${BUILD_PREFIX}/bin"
  merge_link_entries "${CF_PREFIX}/share" "${BUILD_PREFIX}/share"
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

# rattler-build exports SHLIB_EXT=.not_implemented for staging builds;
# derive it from target_platform like conda-build did (install-gcc.sh uses
# it for the shared-library symlinks in lib/gcc/$TARGET/$gcc_version)
if [[ "$target_platform" == osx-* ]]; then
  export SHLIB_EXT=".dylib"
elif [[ "$target_platform" == win-* ]]; then
  export SHLIB_EXT=".dll"
else
  export SHLIB_EXT=".so"
fi
SYSROOT_DIR=${PREFIX}/${TARGET}/sysroot

if [[ "$target_platform" == "osx-"* ]]; then
  STRIP_ARGS=""
else
  STRIP_ARGS="--strip-all"
fi
