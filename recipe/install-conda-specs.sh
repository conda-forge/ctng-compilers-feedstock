#!/bin/bash

source ${RECIPE_DIR}/setup_compiler.sh

set -ex

specdir=$PREFIX/lib/gcc/$TARGET/${gcc_version}
mkdir -p ${specdir}

if [[ "${TARGET}" == "${HOST}" ]]; then
    cp ${SRC_DIR}/build/gcc/specs ${SRC_DIR}/build/gcc/conda.specs
    install -Dm644 ${SRC_DIR}/build/gcc/conda.specs $specdir

    # Add specs when we're not cross compiling so that the toolchain works more like a system
    # toolchain (i.e. conda installed libs can be #include <>'d and linked without adding any
    # cmdline args or FLAGS and likewise the assumptions we have about rpath are built in)
    #
    # THIS IS INTENDED as a safety net for casual users who just want the native toolchain to work.
    # It is not to be relied on by conda-forge package recipes and best practice is still to set the
    # appropriate FLAGS vars (either via compiler activation scripts or explicitly in the recipe)
    #
    # We use double quotes here because we want $PREFIX and $TARGET to be expanded at build time
    #   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
    #   package is installed.
    if [[ "$TARGET" == *linux* ]]; then
      NEW_LINK="%{\!static:-rpath ${PREFIX}/lib -rpath-link ${PREFIX}/lib} -L ${PREFIX}/lib/stubs -L ${PREFIX}/lib"
      sed -i.bak "/\*link_command:/,+1 s+%.*+& ${NEW_LINK}+" $specdir/conda.specs
    elif [[ "$TARGET" == *mingw* ]]; then
      NEW_LINK="-L ${PREFIX}/lib"
      sed -i.bak "/\*link_command:/,+1 s+%.*+& ${NEW_LINK}+" $specdir/conda.specs
    elif [[ "$TARGET" == *darwin* ]]; then
      NEW_LINK="%{\!static:-rpath ${PREFIX}/lib} -L ${PREFIX}/lib"
      sed -i.bak "/\*link_command:/,+1 s+%\(.*\)\}\}\}\}\}\}\}\}\}\}+%\1\}\}\} ${NEW_LINK}\}\}\}\}\}\}\}+" $specdir/conda.specs
      sed -i.bak "s+@loader_path+${PREFIX}/lib+g" $specdir/conda.specs
    fi
    if [[ "${TARGET}" == *linux* ]]; then
      # put -disable-new-dtags at the front of the cmdline so that user provided -enable-new-dtags (in %l) can  override it
      sed -i.bak "/\*link_command:/,+1 s+%(linker)+& -disable-new-dtags +" $specdir/conda.specs
    fi
    # use -idirafter to put the conda "system" includes where /usr/local/include would typically go
    # in a system-packaged non-cross compiler
    sed -i.bak "/\*cpp_options:/,+1 s+%.*+& -idirafter ${PREFIX}/include+" $specdir/conda.specs
    # cc1_options also get used for cc1plus... at least in 11.2.0
    sed -i.bak "/\*cc1_options:/,+1 s+%.*+& -idirafter ${PREFIX}/include+" $specdir/conda.specs

    rm $specdir/conda.specs.bak
else
    # does it even make sense to do anything here?  Could do something with %:getenv(BUILD_PREFIX  /include) 
    # but in the case that we aren't inside conda-build, it will cause gcc to fatal
    # because it won't be set.  Just explicitly making this fail for now so that the meta.yaml
    # is consitent with when it creates the conda-gcc-specs package
    false
fi
