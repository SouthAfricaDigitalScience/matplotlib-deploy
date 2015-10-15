#!/bin/bash -e
#SOURCE_FILE=$NAME-$VERSION.tar.gz
. /usr/share/modules/init/bash
# We will build the code from the github repo, but if we want specific versions,
# a new Jenkins job will be created for the version number and we'll provide
# the URL to the tarball in the configuration.
SOURCE_REPO="https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.4.3/"
# We pretend that the $SOURCE_FILE is there, even though it's actually a dir.
SOURCE_FILE="${NAME}-${VERSION}.tar.gz"
module load ci
echo "Modules available"
module avail
module add gcc/${GCC_VERSION}
module load python/${PYTHON_VERSION}
echo "After python, PYTHONPATH is $PYTHONPATH"
module load numpy/1.9.1
echo "After numpy, PYTHONPATH is $PYTHONPATH"
module load libpng/1.6.18-gcc-1.6.18
echo "Adding Freetype module"
module load freetype/2.6.1

echo "freetype-config command"
which freetype-config
locate freetype-config

echo "Locate the header file"
locate ft2build.h

cat <<PYTHON>python_test.py
import numpy
print("Printing Numpy Version")
print numpy.__version__
PYTHON

echo "Checking to see if we can use numpy"

python python_test.py

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "seems like this is the first build - Let's get the $SOURCE_FILE from $SOURCE_REPO and unarchive to $WORKSPACE"
  mkdir -p $SRC_DIR
  wget $SOURCE_REPO/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
else
  echo "continuing from previous builds, using source at " $SRC_DIR/$SOURCE_FILE
fi

tar -xvz  --keep-newer-files -f $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
cd $WORKSPACE/$NAME-$VERSION

echo "updating PYTHONPATH"
export PYTHONPATH=${PYTHONPATH}:${SOFT_DIR}/lib/python2.7/site-packages/

echo "PATH and LD_LIBRARY_PATH"
echo $PATH
echo $LD_LIBRARY_PATH

echo "freetype-config command"
which freetype-config
locate freetype-config

echo "Locate the header file"
locate ft2build.h

echo "Configuring the build"
python setup.py build
