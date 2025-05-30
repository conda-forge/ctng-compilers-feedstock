# When host=target, gcc installs un-prefixed tools together with prefixed-tools
# In the case of cpp, only un-prefixed cpp. Let's copy the un-prefixed tool
# to prefix-tool and delete the un-prefixed one to get back ct-ng behaviour
for tool in gcc g++ gfortran cpp gcc-ar gcc-nm gcc-ranlib c++; do
  if [ -f ${PREFIX}/bin/${tool}${EXEEXT} ]; then
    if [ ! -f ${PREFIX}/bin/${triplet}-${tool}${EXEEXT} ]; then
      cp ${PREFIX}/bin/${tool}${EXEEXT} ${PREFIX}/bin/${triplet}-${tool}${EXEEXT}
    fi
    rm ${PREFIX}/bin/${tool}${EXEEXT}
  fi
done
