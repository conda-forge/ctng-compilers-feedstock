set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/.build/${CHOST}/build/build-cc-gcc-final/

  make -C ${CHOST}/libgcc prefix=${PREFIX} install-shared

  mkdir -p ${PREFIX}/${CHOST}/sysroot/lib || true
  # TODO :: Also do this for libgfortran (and libstdc++ too probably?)
  sed -i.bak 's/.*cannot install.*/func_warning "Ignoring libtool error about cannot install to a directory not ending in"/' \
             ${CHOST}/libsanitizer/libtool
  for lib in libatomic libgomp libquadmath libitm libvtv libsanitizer/{a,l,ub,t}san; do
    # TODO :: Also do this for libgfortran (and libstdc++ too probably?)
    if [[ -f ${CHOST}/${lib}/libtool ]]; then
      sed -i.bak 's/.*cannot install.*/func_warning "Ignoring libtool error about cannot install to a directory not ending in"/' \
                 ${CHOST}/${lib}/libtool
    fi
  done
  for lib in libatomic libgomp libquadmath libitm libvtv libsanitizer/{a,l,ub,t}san; do
    if [[ -d ${CHOST}/${lib} ]]; then
      make -C ${CHOST}/${lib} prefix=${PREFIX} install-toolexeclibLTLIBRARIES
      make -C ${CHOST}/${lib} prefix=${PREFIX} install-nodist_fincludeHEADERS || true
    fi
  done

  for lib in libquadmath libgomp; do
    if [[ -d ${CHOST}/${lib} ]]; then
      make -C ${CHOST}/${lib} prefix=${PREFIX} install-info
    fi
  done

popd

mkdir -p ${PREFIX}/lib
mv ${PREFIX}/${CHOST}/lib/* ${PREFIX}/lib

for lib in libatomic libgomp libquadmath libitm libvtv lib{a,l,ub,t}san; do
  symtargets=$(find ${PREFIX}/lib -name "${lib}.so*")
  for symtarget in ${symtargets}; do
    symtargetname=$(basename ${symtarget})
    ln -s ${PREFIX}/lib/${symtargetname} ${PREFIX}/${CHOST}/sysroot/lib/${symtargetname}
  done
done

# remove parts of openmp libs that we do not need
for tgt in libgomp.so.1.0.0 libgomp.so.1 libgomp.so; do
    rm ${PREFIX}/lib/${tgt}
    rm ${PREFIX}/${CHOST}/sysroot/lib/${tgt}
done

# TODO remove for conda build > 3.18.11
# hack for conda build bug on symlinks
mkdir -p $PREFIX/bin
for action in post-link pre-unlink; do
    cp $RECIPE_DIR/libgcc-ng-${action}.sh $PREFIX/bin/.libgcc-ng-${action}.sh
    sed -i "1iCHOST=${CHOST}" $PREFIX/bin/.libgcc-ng-${action}.sh
done
# end of hack

# actual code for later
# # make openmp symlinks
# ln -s ${PREFIX}/lib/libgomp.so.1 ${PREFIX}/lib/libgomp.so
# ln -s ${PREFIX}/lib/libgomp.so ${PREFIX}/${CHOST}/sysroot/lib/libgomp.so

# no static libs
find ${PREFIX}/lib -name "*\.a" -exec rm -rf {} \;
# no libtool files
find ${PREFIX}/lib -name "*\.la" -exec rm -rf {} \;
# clean up empty folder
rm -rf ${PREFIX}/lib/gcc

# Install Runtime Library Exception
install -Dm644 ${SRC_DIR}/.build/src/gcc-${PKG_VERSION}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION
