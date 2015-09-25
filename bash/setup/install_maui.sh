#!/bin/bash

TVERSION=2.5.12
MVERSION=3.3
DEFAULTSERVER=nukestar01
REQ_PACKAGES="autotools-dev libltdl-dev libltdl7 libtool"
cd /setup

# install MAUI
echo "    Installing MAUI on the host server"
tar -xzf maui-$MVERSION.tar.gz
cd maui-$MVERSION
./configure --with-pbs --with-spooldir=/var/spool/maui
make 2>&1
make install 2>&1
sed -i 's/RMCFG[NUKESTAR01] TYPE=PBS@RMNMHOST/RMCFG[nukestar01] TYPE=PBS/g' /var/spool/maui/maui.cfg
cp /setup/hostlist /var/spool/pbs/server_priv/hostlist/
echo "    Adding environmental variables"
echo "export PATH=\$PATH:/usr/local/maui/sbin:/usr/local/maui/bin" >>  /root/.bashrc
echo "export PATH=\$PATH:/usr/local/maui/bin" >>  /etc/profile
echo "export HOSTLIST=/var/spool/pbs/server_priv/hostlist/" >> /root/.bashrc
echo "export HOSTLIST=/var/spool/pbs/server_priv/hostlist/" >> /etc/profile
/usr/local/maui/sbin/maui
