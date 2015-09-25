#!/bin/bash

REQ_PACKAGES="autotools-dev libltdl-dev libltdl7 libtool"

#install pbs_mom on node
/setup/torque-package-mom-linux-x86_64.sh --install

#install libraries
apt-get install -y $REQ_PACKAGES
libtool --finish /usr/local/lib

#start pbs_mom
pbs_mom
