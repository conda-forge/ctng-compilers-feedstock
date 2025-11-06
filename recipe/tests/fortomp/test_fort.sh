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
  "${PREFIX}/bin/${triplet}-gfortran" -o hello hello.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./hello
  fi
  rm -f hello

  "${PREFIX}/bin/${triplet}-gfortran" -O3 -fopenmp -ffast-math -o maths maths.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./maths
  fi
  rm -f maths

  "${PREFIX}/bin/${triplet}-gfortran" -fopenmp -o omp-threadprivate omp-threadprivate.f90 -v
  if [[ "${cross_target_platform}" == "${build_platform}" ]]; then
    ./omp-threadprivate
  fi
  rm -f omp-threadprivate

  ${triplet}-gfortran -v
  ${triplet}-gfortran -E -dM - </dev/null
fi
