#!/bin/sh
# ./addhead.sh

REQ_PACKAGES="build-essential gfortran rpm xorg-dev xserver-xorg ssh openssh-server libboost-all-dev libboost-regex-dev"
cd /setup
apt-get update
apt-get install -y $REQ_PACKAGES


##################
#intel compilers installation
##################
# INTEL_FILES="install_intel.sh intel.lic intelCCconfig.ini intelcompilers.conf intelFCconfig.ini intelserialnumber.txt l_cc_p_10.1.025.tar.gz l_fc_p_10.1.025.tar.gz libstdc++5_3.3.6-20_amd64.deb libstdc++5_3.3.6-20_i386.deb"
# check for required files
# for X in $INTEL_FILES
# do
# 	if [ ! -f $X ]; then
# 		echo "I need the file $X to be in the current directory"
# 		exit 1
# 	fi
# done
# 
# run installation script
# ./install_intel.sh
# echo "Done installing intel compliers on nukestar"$NODE

##################
#PBS (torque+MAUI) installation
##################
PBS_FILES="install_pbs-head.sh torque-2.5.5.tar.gz maui-3.3.tar.gz queueconfig/qconfig queueconfig/updatequeue.sh hostlist nodes"
# check for required files
for X in $PBS_FILES
do
	if [ ! -f $X ]; then
		echo "I need the file $X to be in the current directory"
		exit 1
	fi
done

# run installation script
./install_pbs-head.sh
echo "Done installing torque on nukestar"$NODE

# add bootup run pbs_server, maui and pbs_mom
cd /etc/init.d
echo "/usr/local/sbin/pbs_server" >> start_pbs
echo "/usr/local/maui/sbin/maui" >> start_pbs
echo "/usr/local/sbin/pbs_mom" >> start_pbs
chmod +x start_pbs
update-rc.d start_pbs defaults 98 02
