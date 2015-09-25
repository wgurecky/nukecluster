#!/bin/bash

# Installs MCNP6.  Run this script after installing MCNPXv2.7.0
# Ensure you have installed the intel compiler before running this script!
# Must run as root
# Installs mcnp6.mpi to /usr/share/mcnp/v6/bin/.
#

REQ_PACKAGES="binutils libc-dev-bin libc6-dev libgfortran3 libgomp1 linux-libc-dev"
apt-get install -y $REQ_PACKAGES

cd /setup

# build MCNP6 with openmpi support
cd /setup/mcnpv61/MCNP_CODE_611/MCNP611
make realclean

# Note that bits/c++config.h in 64bit debian exists at
# /usr/include/x86_64-linux-gnu/c++/4.9/bits/c++config.h by default
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/include/x86_64-linux-gnu/c++/4.9/bits
MCNPBASE=/usr/share/mcnp
MCNP6DATAPATH=$MCNPBASE/v6/lib
DATAPATH=$MCNPBASE/v6/lib
V6DIR=$MCNPBASE/v6
LIBPATH=$V6DIR/lib
cd /setup/mcnpv61/MCNP_CODE_611/MCNP611/Source
#make build CONFIG="gfortran openmpi nocheap" FOPT="-O2" COPT="-O2" FC=/usr/local/bin/mpif90 CC=/usr/local/bin/mpicc MPICC=/usr/local/bin/mpicc
#make build CONFIG="gfortran openmpi nocheap" FOPT="-O3" COPT="-O3" FCFLAGS=-m64 CXXFLAGS=-m64 CFLAGS=-m64 CFLAGS=-m64 FFLAGS=-m64 FC=mpif90 CC=mpicc MPICC=/usr/local/bin GNUJ=4 LD=/usr/local/bin/mpif90
#make build CONFIG="gfortran openmpi nocheap" FOPT="-O3" COPT="-O3" FC=mpif90 LD=/usr/local/bin/mpif90 CCFLAGS="-L/usr/include/x86_64-linux-gnu/c++/4.9" CFLAGS=-m64 CXXFLAGS=-m64
make build CONFIG="gfortran openmpi nocheap" FOPT="-O3" COPT="-O3" GNUJ=4 \
 FC=/usr/bin/gfortran-4.9 \
 CC=/usr/bin/gcc-4.9

# copy executable and MCNP_DATA to the proper locations
cp  /setup/mcnpv61/MCNP_CODE_611/MCNP611/bin/\* /usr/share/mcnp/v6/bin/.
cp  /setup/mcnpv61/MCNP_DATA.zip /usr/share/mcnp/v6/.
unzip /usr/share/mcnp/v6/MCNP_DATA.zip
mv /usr/share/mcnp/v6/MCNP_DATA /usr/share/mcnp/v6/lib

# change the file permissions on the mcnp6 and mcnp6data directories
chmod -R o-x /usr/share/mcnp/v6
chmod -R o-r /usr/share/mcnp/v6
chgrp -R mcnp6 /usr/share/mcnp/v6
