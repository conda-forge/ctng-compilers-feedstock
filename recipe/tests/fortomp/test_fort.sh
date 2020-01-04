GFORTRAN=$(${PREFIX}/bin/*-gcc -dumpmachine)-gfortran
FFLAGS="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -pipe"

echo " "
echo "++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++"
echo "libs:"
ls -lah ${PREFIX}/lib/*
ls -lah ${PREFIX}/*/sysroot/lib/*
echo "++++++++++++++++++++++++++++++++++++"
echo "++++++++++++++++++++++++++++++++++++"
echo " "

echo "building the test code:"
cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_Fortran_COMPILER=${GFORTRAN} \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    .
