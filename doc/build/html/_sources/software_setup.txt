Base Software 
+++++++++++++

The software install guide is split between the host OS (base system) and the chroot environment
which is effectively the global "compute node" OS.

On the base system we will install:

- Torque+maui job scheduler

In the chroot / compute node environment, the following software will be installed:

* Torque
* Maui
* gcc compilers
* openmpi
* environment-modules
* user specific software:
     - mcnp
     - python packages
     - njoy
     - openmc

Base OS software
-----------------

On the host OS, create a scratch setup/build folder somwhere::

    #mkdir /setup
    #cd /setup

Copy the build scripts from the ``/bash`` folder of this repo into the ``/setup`` folder.

Torque + Maui
-------------

Before the scripts can be executed, the source tarbal for both Torque and Maui must be procured from the adaptivecomputing.com website.::

    #cd /setup
    #wget http://wpfilebase.s3.amazonaws.com/torque/torque-2.5.12.tar.gz
    #wget http://wpfilebase.s3.amazonaws.com/mauischeduler/maui-3.3.tar.gz

Install scripts for Torque_ and Maui_ can be found in the ``/bash`` folder of this repo.  

.. _Maui: http://www.adaptivecomputing.com/products/open-source/maui/
.. _Torque: http://www.adaptivecomputing.com/products/open-source/torque-resource-manager/

Execute the torque and maui install script on the head node (host OS)::

    #chmod +x install_pbs-head.sh
    #./install_pbs-head.sh


Configure Torque
----------------

PBS Queue settings are located in:

PBS queueconfig documentation may be found here.

Configure Maui
--------------

Maui server settings are stored in ``/var/spool/maui.cfg``.  Documentation for this file may be found: .


The hostlist fo Maui is stored in: .


Chroot / Compute Node Software
+++++++++++++++++++++++++++++++

Install the environment-modules package in chroot::  

    #>apt-get install environment-modules

Then update the contents of ``#>/etc/bash.bashrc`` ::

	case "$0" in
		  -sh|sh|*/sh)	modules_shell=sh ;;
	       -ksh|ksh|*/ksh)	modules_shell=ksh ;;
	       -zsh|zsh|*/zsh)	modules_shell=zsh ;;
	    -bash|bash|*/bash)	modules_shell=bash ;;
	esac
	module() { eval `/usr/bin/modulecmd $modules_shell $*`; }


Install PBS_MOM in Compute OS
------------------------------

create scratch directory in chroot::

    #mkdir /srv/nukeroot/setup

chroot ::

    #chroot /srv/nukeroot

Install pbs_mom::

    #cd /setup
    #chmod +x install_pbs-node.sh
    #./install_pbs-node.sh

Check to see if it works::

    #which pbs_mom
    #qnodes

``qnodes`` should output the status of all nodes in the cluster.  See the users guide for how to submit jobs to the queue.


TORQUE / MAUI systemd scripts
++++++++++++++++++++++++++++++

On the head node we must start the ``pbs_server``, ``maui``, and ``pbs_mom`` daemons.  On the compute nodes, only the ``pbs_mom`` service is required.  It is convinient to have these services automatically start on system boot up.  This can be achived by writing simple systemd startup scripts.

Start by creating systemd scripts on the head node::

    #touch /etc/systemd/system/pbs.service
    #touch /usr/bin/pbs

Fill ``/etc/systemd/system/pbs.service`` with the following::

    [Unit]
    Description=Start pbs on head node

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/pbs start
    ExecStop=/usr/bin/pbs stop
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target

Fill ``/usr/bin/pbs`` with::

    start(){
    exec /usr/local/sbin/pbs_server
    exec /usr/local/maui/sbin/maui
    exec /usr/local/sbin/pbs_mom
    }

    stop(){
    killall pbs_mom
    killall maui
    killall pbs_server
    }

    case $1 in
      start|stop) "$1" ;;
    esac

Enable exec on boot with::

    #systemctl enable pbs.service

In the chroot we must do the following::

    #>touch /etc/systemd/system/pbs.service
    #>touch /usr/bin/pbs

Fill ``$>/etc/systemd/system/pbs.service`` with the following::

    [Unit]
    Description=Start pbs monitor on compute node

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/pbs start
    ExecStop=/usr/bin/pbs stop
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target

Fill ``$>/usr/bin/pbs`` with::

    start(){
    exec /usr/local/sbin/pbs_mom
    }

    stop(){
    killall pbs_mom
    }

    case $1 in
      start|stop) "$1" ;;
    esac

Enable exec on boot with::

    #>systemctl enable pbs.service
