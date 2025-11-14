GFORTRAN=$(${PREFIX}/bin/*-gcc -dumpmachine)-gfortran
FFLAGS="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -pipe"

cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_COMPILER=${GFORTRAN} \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    .

if [[ "${target_platform}" == "${build_platform}" ]]; then
  "${PREFIX}/bin/${TARGET}-gfortran" -o hello hello.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./hello
  fi
  rm -f hello

  "${PREFIX}/bin/${TARGET}-gfortran" -O3 -fopenmp -ffast-math -o maths maths.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./maths
  fi
  rm -f maths

  "${PREFIX}/bin/${TARGET}-gfortran" -fopenmp -o omp-threadprivate omp-threadprivate.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./omp-threadprivate
  fi
  rm -f omp-threadprivate

  ${TARGET}-gfortran -v
  ${TARGET}-gfortran -E -dM - </dev/null
fi
