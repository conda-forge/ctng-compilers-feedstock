#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x



mkdir -p ${PREFIX}/lib

pushd ${SRC_DIR}/build

  # TODO :: Also do this for libgfortran (and libstdc++ too probably?)
  sed -i.bak 's/.*cannot install.*/func_warning "Ignoring libtool error about cannot install to a directory not ending in"/' \
             ${TARGET}/libsanitizer/libtool
  for lib in libsanitizer/{a,hwa,l,ub,t}san; do
    # TODO :: Also do this for libgfortran (and libstdc++ too probably?)
    if [[ -f ${TARGET}/${lib}/libtool ]]; then
      sed -i.bak 's/.*cannot install.*/func_warning "Ignoring libtool error about cannot install to a directory not ending in"/' \
                 ${TARGET}/${lib}/libtool
    fi
    if [[ -d ${TARGET}/${lib} ]]; then
      make -C ${TARGET}/${lib} prefix=${PREFIX} install-toolexeclibLTLIBRARIES
      make -C ${TARGET}/${lib} prefix=${PREFIX} install-nodist_fincludeHEADERS || true
    fi
  done

popd

# no static libs
find ${PREFIX}/lib -name "*\.a" ! -name "*\.dll\.a" -exec rm -rf {} \;
# no libtool files
find ${PREFIX}/lib -name "*\.la" -exec rm -rf {} \;
