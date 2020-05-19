set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

pushd ${SRC_DIR}/.build/${CHOST}/build/build-duma
  make prefix=${PREFIX} HOSTCC=$(uname -m)-build_pc-linux-gnu-gcc CC=${CHOST}-gcc CXX=${CHOST}-g++ RANLIB=${CHOST}-ranlib OS=linux DUMA_CPP=1 install
popd

if [[ "${ctng_cpu_arch}" == "x86_64" ]]; then
  old_vendor="-conda_cos6-linux-gnu-"
else
  old_vendor="-conda_cos7-linux-gnu-"
fi

for exe in `ls ${PREFIX}/bin/*-conda-linux-gnu-*`; do
  nm=`basename ${exe}`
  new_nm=${nm/"-conda-linux-gnu-"/${old_vendor}}
  if [ ! -f ${PREFIX}/bin/${new_nm} ]; then
    ln -s ${exe} ${PREFIX}/bin/${new_nm}
  fi
done
