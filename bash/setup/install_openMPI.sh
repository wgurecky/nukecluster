#!/bin/bash
#this script installs openMPI bit on the local machine

VERSION="1.6.5"
REQ_PACKAGES="libc++-dev"

# install required packages
apt-get install -y $REQ_PACKAGES
dpkg -i libtorque2_2.4.16+dfsg-1.5_amd64.deb
dpkg -i libtorque2-dev_2.4.16+dfsg-1.5_amd64.deb

cd /setup

echo "Unzipping openMPI source code"
tar -xzf openmpi-$VERSION.tar.gz
cd ./openmpi-$VERSION

# install openMPI 64bit with hererogeneous cluster and torque support
echo "    Installing openMPI"
ln  -s  /usr/include/x86_64-linux-gnu/asm  /usr/include/asm #need to link this to make it work!

#############
#   INTEL   #
#############
#./configure CC=icc CXX=icpc F77=ifort FC=ifort CFLAGS=-m64 CXXFLAGS=-m64 FFLAGS=-m64 FCFLAGS=-m64 CFLAGS=-O3 FFLAGS=-O3 CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --enable-heterogeneous --enable-contrib-no-build=vt
#./configure CC=icc CXX=icpc F77=ifort FC=ifort CFLAGS=-m64 CXXFLAGS=-m64 FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --enable-heterogeneous --enable-contrib-no-build=vt

#############
#   GCC     #
#############
#64bit
./configure CC=gcc CXX=g++ F77=gfortran FC=gfortran CFLAGS=-m64 CXXFLAGS=-m64 FFLAGS=-m64 FCFLAGS=-m64 CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --enable-heterogeneous --enable-contrib-no-build=vt --enable-multilib
#./configure CC=gcc CXX=g++ F77=gfortran FC=gfortran CFLAGS=-m64 CXXFLAGS=-m64 FFLAGS=-m64 FCFLAGS=-m64 CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --disable-multilib --enable-contrib-no-build=vt

#32bit
#./configure CC=gcc CXX=g++ F77=gfortran FC=gfortran CFLAGS=-m32 CXXFLAGS=-m32 FFLAGS=-m32 FCFLAGS=-m32 CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --enable-heterogeneous --enable-contrib-no-build=vt
#./configure CC=gcc CXX=g++ F77=gfortran FC=gfortran CPPFLAGS=-I/usr/include/x86_64-linux-gnu --with-tm --enable-contrib-no-build=vt

make
make install

echo "Done installing openMPI"

echo "Processing ldconfig"
ldconfig

cd /setup

exit
