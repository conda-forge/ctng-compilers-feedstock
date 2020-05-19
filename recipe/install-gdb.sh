set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# libtool wants to use ranlib that is here
# for psuedo-cross, depending on the build and host,
# build-gdb-native could be used (it will have been built
# with the newer GCC instead of the system one).
pushd ${SRC_DIR}/.build/${CHOST}/build/build-gdb-cross
  PATH=${SRC_DIR}/.build/${CHOST}/buildtools/bin:$PATH \
  make prefix=${PREFIX} install
  # Gets installed by binutils:
  rm ${PREFIX}/share/info/bfd.info
popd

set +x
# Strip executables, we may want to install to a different prefix
# and strip in there so that we do not change files that are not
# part of this package.
pushd ${PREFIX}
  _files=$(find . -type f)
  for _file in ${_files}; do
    _type="$( file "${_file}" | cut -d ' ' -f 2- )"
    case "${_type}" in
      *script*executable*)
      ;;
      *executable*)
        ${SRC_DIR}/gcc_built/bin/${CHOST}-strip --strip-all -v "${_file}" || :
      ;;
    esac
  done
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
