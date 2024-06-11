About ctng-compilers-feedstock-feedstock
========================================

Feedstock license: [BSD-3-Clause](https://github.com/conda-forge/ctng-compilers-feedstock/blob/main/LICENSE.txt)


About ctng-compilers-feedstock
------------------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: GNU Compiler Collection

About libgomp
-------------

Home: https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: The GCC OpenMP implementation.

About _openmp_mutex
-------------------

Home: https://github.com/conda-forge/ctng-compilers-feedstock

Package license: BSD-3-Clause

Summary: OpenMP Implementation Mutex

About libgcc
------------

Home: https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: The GCC low-level runtime library

About libgfortran5
------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: The GNU Fortran Runtime Library

About libstdcxx
---------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: The GNU C++ Runtime Library

About gcc_impl_win-64
---------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: GNU C Compiler

About libgfortran
-----------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: The GNU Fortran Runtime Library

About conda-gcc-specs
---------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: conda-specific specfile for GNU C/C++ Compiler

Documentation: https://gcc.gnu.org/onlinedocs/gcc/Spec-Files.html

When installed, this optional package provides a specfile that
directs gcc (and g++ or gfortran) to automatically:
  * search for includes in $PREFIX/include
  * link libraries in $PREFIX/lib
  * set RPATH to $PREFIX/lib
  * use RPATH instead of the newer RUNPATH
This package is intended to aid usability of the compiler
toolchain as a replacement for system-installed compilers.
It should not be used in recipes.  Use the 'compiler(<lang>)'
jinja function as described on
https://conda-forge.org/docs/maintainer/knowledge_base.html#dep-compilers


About gfortran_impl_win-64
--------------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: GNU Fortran Compiler

About gxx_impl_win-64
---------------------

Home: https://gcc.gnu.org/

Package license: GPL-3.0-only WITH GCC-exception-3.1

Summary: GNU C++ Compiler

Current build status
====================


<table>
    
  <tr>
    <td>Azure</td>
    <td>
      <details>
        <summary>
          <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=8107&branchName=main">
            <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/ctng-compilers-feedstock?branchName=main">
          </a>
        </summary>
        <table>
          <thead><tr><th>Variant</th><th>Status</th></tr></thead>
          <tbody><tr>
              <td>win_64_cross_target_platformwin-64cross_target_stdlibm2w64-sysrootcross_target_stdlib_version12gcc_version13.2.0tripletx86_64-w64-mingw32</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=8107&branchName=main">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/ctng-compilers-feedstock?branchName=main&jobName=win&configuration=win%20win_64_cross_target_platformwin-64cross_target_stdlibm2w64-sysrootcross_target_stdlib_version12gcc_version13.2.0tripletx86_64-w64-mingw32" alt="variant">
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </details>
    </td>
  </tr>
</table>

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-_openmp_mutex-green.svg)](https://anaconda.org/conda-forge/_openmp_mutex) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/_openmp_mutex.svg)](https://anaconda.org/conda-forge/_openmp_mutex) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/_openmp_mutex.svg)](https://anaconda.org/conda-forge/_openmp_mutex) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/_openmp_mutex.svg)](https://anaconda.org/conda-forge/_openmp_mutex) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-conda--gcc--specs-green.svg)](https://anaconda.org/conda-forge/conda-gcc-specs) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/conda-gcc-specs.svg)](https://anaconda.org/conda-forge/conda-gcc-specs) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/conda-gcc-specs.svg)](https://anaconda.org/conda-forge/conda-gcc-specs) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/conda-gcc-specs.svg)](https://anaconda.org/conda-forge/conda-gcc-specs) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-gcc_impl_win--64-green.svg)](https://anaconda.org/conda-forge/gcc_impl_win-64) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/gcc_impl_win-64.svg)](https://anaconda.org/conda-forge/gcc_impl_win-64) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/gcc_impl_win-64.svg)](https://anaconda.org/conda-forge/gcc_impl_win-64) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/gcc_impl_win-64.svg)](https://anaconda.org/conda-forge/gcc_impl_win-64) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-gfortran_impl_win--64-green.svg)](https://anaconda.org/conda-forge/gfortran_impl_win-64) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/gfortran_impl_win-64.svg)](https://anaconda.org/conda-forge/gfortran_impl_win-64) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/gfortran_impl_win-64.svg)](https://anaconda.org/conda-forge/gfortran_impl_win-64) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/gfortran_impl_win-64.svg)](https://anaconda.org/conda-forge/gfortran_impl_win-64) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-gxx_impl_win--64-green.svg)](https://anaconda.org/conda-forge/gxx_impl_win-64) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/gxx_impl_win-64.svg)](https://anaconda.org/conda-forge/gxx_impl_win-64) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/gxx_impl_win-64.svg)](https://anaconda.org/conda-forge/gxx_impl_win-64) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/gxx_impl_win-64.svg)](https://anaconda.org/conda-forge/gxx_impl_win-64) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libgcc-green.svg)](https://anaconda.org/conda-forge/libgcc) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libgcc.svg)](https://anaconda.org/conda-forge/libgcc) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libgcc.svg)](https://anaconda.org/conda-forge/libgcc) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libgcc.svg)](https://anaconda.org/conda-forge/libgcc) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libgfortran-green.svg)](https://anaconda.org/conda-forge/libgfortran) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libgfortran.svg)](https://anaconda.org/conda-forge/libgfortran) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libgfortran.svg)](https://anaconda.org/conda-forge/libgfortran) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libgfortran.svg)](https://anaconda.org/conda-forge/libgfortran) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libgfortran5-green.svg)](https://anaconda.org/conda-forge/libgfortran5) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libgfortran5.svg)](https://anaconda.org/conda-forge/libgfortran5) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libgfortran5.svg)](https://anaconda.org/conda-forge/libgfortran5) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libgfortran5.svg)](https://anaconda.org/conda-forge/libgfortran5) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libgomp-green.svg)](https://anaconda.org/conda-forge/libgomp) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libgomp.svg)](https://anaconda.org/conda-forge/libgomp) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libgomp.svg)](https://anaconda.org/conda-forge/libgomp) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libgomp.svg)](https://anaconda.org/conda-forge/libgomp) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libstdcxx-green.svg)](https://anaconda.org/conda-forge/libstdcxx) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libstdcxx.svg)](https://anaconda.org/conda-forge/libstdcxx) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libstdcxx.svg)](https://anaconda.org/conda-forge/libstdcxx) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libstdcxx.svg)](https://anaconda.org/conda-forge/libstdcxx) |

Installing ctng-compilers-feedstock
===================================

Installing `ctng-compilers-feedstock` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
conda config --set channel_priority strict
```

Once the `conda-forge` channel has been enabled, `_openmp_mutex, conda-gcc-specs, gcc_impl_win-64, gfortran_impl_win-64, gxx_impl_win-64, libgcc, libgfortran, libgfortran5, libgomp, libstdcxx` can be installed with `conda`:

```
conda install _openmp_mutex conda-gcc-specs gcc_impl_win-64 gfortran_impl_win-64 gxx_impl_win-64 libgcc libgfortran libgfortran5 libgomp libstdcxx
```

or with `mamba`:

```
mamba install _openmp_mutex conda-gcc-specs gcc_impl_win-64 gfortran_impl_win-64 gxx_impl_win-64 libgcc libgfortran libgfortran5 libgomp libstdcxx
```

It is possible to list all of the versions of `_openmp_mutex` available on your platform with `conda`:

```
conda search _openmp_mutex --channel conda-forge
```

or with `mamba`:

```
mamba search _openmp_mutex --channel conda-forge
```

Alternatively, `mamba repoquery` may provide more information:

```
# Search all versions available on your platform:
mamba repoquery search _openmp_mutex --channel conda-forge

# List packages depending on `_openmp_mutex`:
mamba repoquery whoneeds _openmp_mutex --channel conda-forge

# List dependencies of `_openmp_mutex`:
mamba repoquery depends _openmp_mutex --channel conda-forge
```


About conda-forge
=================

[![Powered by
NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](https://numfocus.org)

conda-forge is a community-led conda channel of installable packages.
In order to provide high-quality builds, the process has been automated into the
conda-forge GitHub organization. The conda-forge organization contains one repository
for each of the installable packages. Such a repository is known as a *feedstock*.

A feedstock is made up of a conda recipe (the instructions on what and how to build
the package) and the necessary configurations for automatic building using freely
available continuous integration services. Thanks to the awesome service provided by
[Azure](https://azure.microsoft.com/en-us/services/devops/), [GitHub](https://github.com/),
[CircleCI](https://circleci.com/), [AppVeyor](https://www.appveyor.com/),
[Drone](https://cloud.drone.io/welcome), and [TravisCI](https://travis-ci.com/)
it is possible to build and upload installable packages to the
[conda-forge](https://anaconda.org/conda-forge) [anaconda.org](https://anaconda.org/)
channel for Linux, Windows and OSX respectively.

To manage the continuous integration and simplify feedstock maintenance
[conda-smithy](https://github.com/conda-forge/conda-smithy) has been developed.
Using the ``conda-forge.yml`` within this repository, it is possible to re-render all of
this feedstock's supporting files (e.g. the CI configuration files) with ``conda smithy rerender``.

For more information please check the [conda-forge documentation](https://conda-forge.org/docs/).

Terminology
===========

**feedstock** - the conda recipe (raw material), supporting scripts and CI configuration.

**conda-smithy** - the tool which helps orchestrate the feedstock.
                   Its primary use is in the construction of the CI ``.yml`` files
                   and simplify the management of *many* feedstocks.

**conda-forge** - the place where the feedstock and smithy live and work to
                  produce the finished article (built conda distributions)


Updating ctng-compilers-feedstock-feedstock
===========================================

If you would like to improve the ctng-compilers-feedstock recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`conda-forge` channel, whereupon the built conda packages will be available for
everybody to install and use from the `conda-forge` channel.
Note that all branches in the conda-forge/ctng-compilers-feedstock-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@beckermr](https://github.com/beckermr/)
* [@isuruf](https://github.com/isuruf/)
* [@timsnyder](https://github.com/timsnyder/)
* [@xhochy](https://github.com/xhochy/)

