mkdir -p ${PREFIX}/${CHOST}/sysroot/lib64
# if the old one exists and is not a symbolic link
if [ -d "${PREFIX}/${CHOST}/sysroot/lib" && ! -L "${PREFIX}/${CHOST}/sysroot/lib" ]; then
  mv ${PREFIX}/${CHOST}/sysroot/lib/* ${PREFIX}/${CHOST}/sysroot/lib64
  rm -rf ${PREFIX}/${CHOST}/sysroot/lib
fi
