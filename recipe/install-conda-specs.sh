set -ex
export CHOST="${gcc_machine}-${gcc_vendor}-linux-gnu"


# generate specfile so that we can patch loader link path
# link_libgcc should have the gcc's own libraries by default (-R)
# so that LD_LIBRARY_PATH isn't required for basic libraries.
#
# GF method here to create specs file and edit it.  The other methods
# tried had no effect on the result.  including:
#   setting LINK_LIBGCC_SPECS on configure
#   setting LINK_LIBGCC_SPECS on make
#   setting LINK_LIBGCC_SPECS in gcc/Makefile
specdir=$PREFIX/lib/gcc/$CHOST/${gcc_version}
if [[ "$build_platform" == "$target_platform" ]]; then
    $PREFIX/bin/${CHOST}-gcc -dumpspecs > $specdir/specs
else
    $BUILD_PREFIX/bin/${CHOST}-gcc -dumpspecs > $specdir/specs
fi

# make a copy of the specs without our additions so that people can choose not to use them
# by passing -specs=builtin.specs
cp $specdir/specs $specdir/builtin.specs

# We use double quotes here because we want $PREFIX and $CHOST to be expanded at build time
#   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
#   package is installed.
if [[ "$cross_target_platform" == "$target_platform" && "$PKG_BUILD_STRING" == *_extended ]]; then

    # Add specs when we're not cross compiling so that the toolchain works more like a system
    # toolchain (i.e. conda installed libs can be #include <>'d and linked without adding any
    # cmdline args or FLAGS and likewise the assumptions we have about rpath are built in)
    #
    # THIS IS INTENDED as a safety net for casual users who just want the native toolchain to work.
    # It is not to be relied on by conda-forge package recipes and best practice is still to set the
    # appropriate FLAGS vars (either via compiler activation scripts or explicitly in the recipe)
    #
    # We use double quotes here because we want $PREFIX and $CHOST to be expanded at build time
    #   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
    #   package is installed.
    sed -i -e "/\*link_command:/,+1 s+%.*+& %{\!static:-rpath ${PREFIX}/lib -rpath-link ${PREFIX}/lib -disable-new-dtags} -L ${PREFIX}/lib+" $specdir/specs
    # use -idirafter to put the conda "system" includes where /usr/local/include would typically go
    # in a system-packaged non-cross compiler
    sed -i -e "/\*cpp_options:/,+1 s+%.*+& -idirafter ${PREFIX}/include+" $specdir/specs
    # cc1_options also get used for cc1plus... at least in 11.2.0
    sed -i -e "/\*cc1_options:/,+1 s+%.*+& -idirafter ${PREFIX}/include+" $specdir/specs

else
    # 'minimal' specs were the default for gcc and were made across all cross_target_platform carry that behavior forward
    sed -i -e "/\*link_command:/,+1 s+%.*+& %{!static:-rpath ${PREFIX}/lib -disable-new-dtags}+" $specdir/specs
fi
