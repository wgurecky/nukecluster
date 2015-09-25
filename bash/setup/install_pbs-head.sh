#!/bin/bash

TVERSION=2.5.12
MVERSION=3.3
DEFAULTSERVER=nukestar01
REQ_PACKAGES="autotools-dev libltdl-dev libltdl7 libtool"

cd /setup

#install torque
if [ ! -d torque-$TVERSION ]; then
	echo "    Installing Torque on the host server"
	# remove old installations
	rm -r /var/spool/pbs

	# decompress soure code
	tar -xzf torque-$TVERSION.tar.gz
	cd torque-$TVERSION
	./configure --with-default-server=$DEFAULTSERVER --with-server-home=/var/spool/pbs --with-rcp=scp
	make
	make install

	# add libraries
	apt-get install -y $REQPACKAGES
	libtool --finish /usr/local/lib

	#update nodes file
	cp /var/spool/pbs/server_priv/nodes /var/spool/pbs/server_priv/nodes.orig
	cat /setup/nodes >> /var/spool/pbs/server_priv/nodes

	# setup pbs server
	./torque.setup root
	qmgr -c 'p s'

	# restart pbs_server
	qterm -t quick
	pbs_server

	# create queues
	cd /setup/queueconfig
	sh updatequeue.sh

	# make install packages for worker nodes
	cd /setup/torque-$TVERSION
	make packages 2>&1 | tee torque_makepackages.txt
	cp ./torque-package-mom-linux-x86_64.sh /setup/torque-package-mom-linux-x86_64.sh
fi

cd /setup

# install MAUI
if [ ! -d maui-$MVERSION ]; then
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
fi

cd /setup

#echo "   Placing startup scripts in init.d"
#cp torque-server /etc/init.d/.
#update-rc.d torque-server defaults
#cp torque-node /etc/init.d/.
#update-rc.d torque-node defaults

echo "   Done installing torque and Maui"
exit
