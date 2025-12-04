#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh
set -e -x

_libdir=libexec/gcc/${TARGET}/${PKG_VERSION}

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
#export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${TARGET}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/build
  # We may not have built with plugin support so failure here is not fatal:
  make prefix=${PREFIX} install-lto-plugin || true

  sed -i.bak 's/install-collect2: collect2 /install-collect2: collect2$(exeext) /g' gcc/Makefile
  make -C gcc prefix=${PREFIX} install-driver install-cpp install-gcc-ar install-headers install-plugin install-lto-wrapper install-collect2
  # not sure if this is the same as the line above.  Run both, just in case
  make -C lto-plugin prefix=${PREFIX} install || true
  install -dm755 ${PREFIX}/lib/bfd-plugins/ || true

  # statically linked, so this so does not exist
  # ln -s $PREFIX/lib/gcc/$TARGET/liblto_plugin.so ${PREFIX}/lib/bfd-plugins/

  make -C libcpp prefix=${PREFIX} install

  # Include languages we do not have any other place for here (and also lto1)
  for file in gnat1 brig1 cc1 go1 lto1 cc1obj cc1objplus; do
    if [[ -f gcc/${file}${EXEEXT} ]]; then
      install -c gcc/${file}${EXEEXT} ${PREFIX}/${_libdir}/${file}${EXEEXT}
    fi
  done

  # https://github.com/gcc-mirror/gcc/blob/gcc-7_3_0-release/gcc/Makefile.in#L3481-L3526
  # Could have used install-common, but it also installs cxx binaries, which we
  # don't want in this package. We could patch it, or use the loop below:
  for file in gcov{,-tool,-dump}; do
    if [[ -f gcc/${file}${EXEEXT} ]]; then
      install -c gcc/${file}${EXEEXT} ${PREFIX}/bin/${TARGET}-${file}${EXEEXT}
    fi
  done

  make prefix=${PREFIX}/lib/gcc/${TARGET}/${gcc_version} install-libcc1
  install -d ${PREFIX}/share/gdb/auto-load/usr/lib

  make prefix=${PREFIX} install-fixincludes
  make -C gcc prefix=${PREFIX} install-mkheaders

  if [[ -d ${TARGET}/libatomic ]]; then
    make -C ${TARGET}/libatomic prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libgomp ]]; then
    make -C ${TARGET}/libgomp prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libitm ]]; then
    make -C ${TARGET}/libitm prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libquadmath ]]; then
    make -C ${TARGET}/libquadmath prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libsanitizer ]]; then
    make -C ${TARGET}/libsanitizer prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libsanitizer/asan ]]; then
    make -C ${TARGET}/libsanitizer/asan prefix=${PREFIX} install
  fi

  if [[ -d ${TARGET}/libsanitizer/tsan ]]; then
    make -C ${TARGET}/libsanitizer/tsan prefix=${PREFIX} install
  fi

  make -C libiberty prefix=${PREFIX} install
  # install PIC version of libiberty
  if [[ "${TARGET}" != *mingw* ]]; then
    install -m644 libiberty/pic/libiberty.a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}
  else
    install -m644 libiberty/libiberty.a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}
  fi

  make -C gcc prefix=${PREFIX} install-man install-info

  make -C gcc prefix=${PREFIX} install-po

  # many packages expect this symlink
  [[ -f ${PREFIX}/bin/${TARGET}-cc${EXEEXT} ]] && rm ${PREFIX}/bin/${TARGET}-cc${EXEEXT}
  pushd ${PREFIX}/bin
    if [[ "${HOST}" != *mingw* ]]; then
      ln -s ${TARGET}-gcc${EXEEXT} ${TARGET}-cc${EXEEXT}
    else
      cp ${TARGET}-gcc${EXEEXT} ${TARGET}-cc${EXEEXT}
    fi
  popd

  # POSIX conformance launcher scripts for c89 and c99
  cat > ${PREFIX}/bin/${TARGET}-c89${EXEEXT} <<"EOF"
#!/bin/sh
fl="-std=c89"
for opt; do
  case "$opt" in
    -ansi|-std=c89|-std=iso9899:1990) fl="";;
    -std=*) echo "`basename $0` called with non ANSI/ISO C option $opt" >&2
      exit 1;;
  esac
done
exec ${TARGET}-c89${EXEEXT} $fl ${1+"$@"}
EOF

  cat > ${PREFIX}/bin/${TARGET}-c99${EXEEXT} <<"EOF"
#!/bin/sh
fl="-std=c99"
for opt; do
  case "$opt" in
    -std=c99|-std=iso9899:1999) fl="";;
    -std=*) echo "`basename $0` called with non ISO C99 option $opt" >&2
      exit 1;;
  esac
done
exec ${TARGET}-c99${EXEEXT} $fl ${1+"$@"}
EOF

  chmod 755 ${PREFIX}/bin/${TARGET}-c{8,9}9${EXEEXT}

  rm ${PREFIX}/bin/${TARGET}-gcc-${PKG_VERSION}${EXEEXT}

popd

# generate specfile so that we can patch loader link path
# link_libgcc should have the gcc's own libraries by default (-R)
# so that LD_LIBRARY_PATH isn't required for basic libraries.
#
# GF method here to create specs file and edit it.  The other methods
# tried had no effect on the result.  including:
#   setting LINK_LIBGCC_SPECS on configure
#   setting LINK_LIBGCC_SPECS on make
#   setting LINK_LIBGCC_SPECS in gcc/Makefile
specdir=$PREFIX/lib/gcc/$TARGET/${gcc_version}
cp ${SRC_DIR}/build/gcc/specs $specdir/specs
cat $specdir/specs

# make a copy of the specs without our additions so that people can choose not to use them
# by passing -specs=builtin.specs
cp $specdir/specs $specdir/builtin.specs

# modify the default specs to only have %include_noerr that includes an optional conda.specs
# package installable via the conda-gcc-specs package where conda.specs (for ${TARGET}
# == ${HOST}) will add the minimal set of flags for the 'native' toolchains to be useable
# without anything additional set in the enviornment or extra cmdline args.
echo  "%include_noerr <conda.specs>" >> $specdir/specs

# We use double quotes here because we want $PREFIX and $TARGET to be expanded at build time
#   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
#   package is installed.
if [[ "${TARGET}" == *linux* ]]; then
  sed -i.bak "/\*link_command:/,+1 s+%.*+& %{!static:-rpath ${PREFIX}/lib}+" $specdir/specs
elif [[ "${TARGET}" == *darwin* ]]; then
  sed -i.bak "s#@loader_path#${PREFIX}/lib#g" $specdir/specs
fi
rm -f $specdir/specs.bak

mkdir -p ${PREFIX}/share/licenses/gcc

# Install Runtime Library Exception
install -Dm644 $SRC_DIR/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/gcc/RUNTIME.LIBRARY.EXCEPTION

set +x
# Strip executables, we may want to install to a different prefix
# and strip in there so that we do not change files that are not
# part of this package.
pushd ${PREFIX}
  _files=$(find bin libexec -type f -not -name '*.dll')
  for _file in ${_files}; do
    _type="$( file "${_file}" | cut -d ' ' -f 2- )"
    case "${_type}" in
      *script*executable*)
      ;;
      *executable*)
        ${BUILD_PREFIX}/bin/${HOST}-strip ${STRIP_ARGS} -v "${_file}" || :
      ;;
    esac
  done
popd

set -x

#${PREFIX}/bin/${TARGET}-gcc "${RECIPE_DIR}"/c11threads.c -std=c11

mkdir -p ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}

if [[ "${HOST}" == "${TARGET}" ]]; then
  if [[ "${TARGET}" == *darwin* ]]; then
    rm -rf ${PREFIX}/lib/libgomp.*dylib
    rm -rf ${PREFIX}/lib/libgomp.a
  fi
  # making these this way so conda build doesn't muck with them
  pushd ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
    if [[ "${TARGET}" == *darwin* ]]; then
      ln -sf ../../../libomp.dylib libgomp.dylib
    fi
    for name in atomic gomp cc1 itm quadmath {a,hwa,l,t,ub}san; do
      [ -e "${PREFIX}/lib/lib${name}${SHLIB_EXT}" ] || continue
      ln -s ../../../lib${name}${SHLIB_EXT} lib${name}${SHLIB_EXT}
    done
  popd
else
  source ${RECIPE_DIR}/install-libgcc.sh
  if [[ "${TARGET}" == *darwin* ]]; then
    rm -rf ${PREFIX}/${TARGET}/lib/libgomp.*dylib
    rm -rf ${PREFIX}/${TARGET}/lib/libgomp.a
  fi
  rm -f ${PREFIX}/share/info/*.info
  # TODO: create a TBD file libgomp.tbd that re-exports libomp.dylib
  # and remove libgomp.dylib symlink from _openmp_mutex
  for name in atomic gomp cc1 itm quadmath {a,hwa,l,t,ub}san; do
    if [[ -f "${PREFIX}/${TARGET}/lib/lib${name}.so" ]]; then
      mv ${PREFIX}/${TARGET}/lib/lib${name}.so* ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/ || true
    fi
    if [[ -f "${PREFIX}/${TARGET}/lib/lib${name}.dylib" ]]; then
      mv ${PREFIX}/${TARGET}/lib/lib${name}.*dylib ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/ || true
    fi
  done
fi
  
mkdir -p ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
for name in atomic gomp itm quadmath {a,hwa,l,t,ub}san; do
  if [[ -f "${PREFIX}/lib/lib${name}.a" ]]; then
   mv ${PREFIX}/lib/lib${name}.*a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
  fi
  if [[ -f "${PREFIX}/${TARGET}/lib/lib${name}.a" ]]; then
   mv ${PREFIX}/${TARGET}/lib/lib${name}.*a ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/
  fi
done

for f in ${PREFIX}/lib/*.spec; do
  [ -e "$f" ] || continue
  mv $f ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/$(basename $f)
done
for f in ${PREFIX}/${TARGET}/lib/*.spec; do
  [ -e "$f" ] || continue
  mv $f ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/$(basename $f)
done
if [[ "${TARGET}" == *linux* ]]; then
  # sanitizer preinit files
  for f in ${PREFIX}/lib/*.o; do
    [ -e "$f" ] || continue
    mv $f ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/$(basename $f)
  done
  for f in ${PREFIX}/${TARGET}/lib/*.o; do
    [ -e "$f" ] || continue
    mv $f ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/$(basename $f)
  done
fi
rm -f ${PREFIX}/share/info/dir

mkdir -p ${PREFIX}/libexec/gcc/${TARGET}/${gcc_version}
if [[ "${TARGET}" == *darwin* ]]; then
  TOOLS="ar as c++filt ld nm ranlib size strings strip"
elif [[ "${TARGET}" == *linux* ]]; then
  TOOLS=TOOLS="addr2line ar c++filt elfedit ld nm objcopy objdump ranlib readelf size strings strip"
elif [[ "${TARGET}" == *mingw* ]]; then
  TOOLS=""
  #TOOLS=TOOLS="addr2line ar c++filt elfedit ld nm objcopy objdump ranlib readelf size strings strip dlltool dllwrap windmc windres"
fi

for f in ${TOOLS}; do
  ln -sf ${PREFIX}/bin/${TARGET}-${f} ${PREFIX}/libexec/gcc/${TARGET}/${gcc_version}/${f}
done

if [[ "${TARGET}" == *darwin* ]]; then
  # stdio.h from the SDK is vendored and "fixed" here, but we need to allow
  # using different SDKs
  rm -f ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/include-fixed/stdio.h
  # same here, but we need to support __FLT_EVAL_METHOD__=16 on older SDKs
  cp ${RECIPE_DIR}/include-fixed-math.h ${PREFIX}/lib/gcc/${TARGET}/${gcc_version}/include-fixed/math.h
fi

source ${RECIPE_DIR}/make_tool_links.sh
