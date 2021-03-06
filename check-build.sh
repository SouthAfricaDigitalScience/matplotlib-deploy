#!/bin/bash

. /usr/share/modules/init/bash
module load ci
module load python/2.7.9
module load numpy/1.9.1
module load libpng/1.6.18-gcc-1.6.18
module load freetype/2.6.1
module load mpc/1.0.1


echo "Running python check"
cd $WORKSPACE/$NAME-$VERSION
python setup.py check

echo $?
if [ $? != 0 ] ; then
  exit 1
fi


echo "Running python install"
echo "updating PYTHONPATH"
export PYTHONPATH=${PYTHONPATH}:${SOFT_DIR}/lib/python2.7/site-packages/
echo $PYTHONPATH
python setup.py install --prefix=$SOFT_DIR

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
   puts stderr "\tAdds $NAME $VERSION to your environment"
}


module-whatis   "$NAME $VERSION."
setenv       MATPLOTLIB_VERSION       $VERSION
setenv       MATPLOTLIB_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION

prepend-path    PYTHONPATH      /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}/lib/python2.7/site-packages/
prepend-path 	  PATH            $::env(MATPLOTLIB_DIR)/bin
prepend-path    PATH            $::env(MATPLOTLIB_DIR)/include
prepend-path    PATH            $::env(MATPLOTLIB_DIR)/bin
prepend-path    MANPATH         $::env(MATPLOTLIB_DIR)/man
prepend-path    LD_LIBRARY_PATH $::env(MATPLOTLIB_DIR)/lib
MODULE_FILE
) > modules/$VERSION
mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME/$VERSION

# Testing module
module avail
module list
