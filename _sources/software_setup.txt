Base Software 
+++++++++++++

The software install guide is split between the host OS (base system) and the chroot environment
which is effectively the global "compute node" OS.

On the base system we will install:

- Torque+maui job scheduler

In the chroot / compute node environment, the following software will be installed:

* Torque
* Maui
* environment-modules
* user specific software:
     - mcnp
     - python packages
     - njoy

Base OS software
-----------------

On the host OS, create a scratch setup/build folder somwhere::

    #mkdir /setup
    #cd /setup

Copy the build scripts from the ``/bash`` folder of this repo into the ``/setup`` folder.

Torque + Maui
-------------

Before the scripts can be executed, the source tarball for both Torque and Maui must be procured from the adaptivecomputing.com website.::

    #cd /setup
    #wget http://wpfilebase.s3.amazonaws.com/torque/torque-6.1.0.tar.gz
    #wget http://wpfilebase.s3.amazonaws.com/mauischeduler/maui-3.3.1.tar.gz

.. Note::
	In order to download the Maui software package, you must first create an account
	on the adaptivecomputing.com website.

Install scripts for Torque_ and Maui_ can be found in the ``/bash`` folder of this repo.  

.. _Maui: http://www.adaptivecomputing.com/products/open-source/maui/
.. _Torque: http://www.adaptivecomputing.com/products/open-source/torque-resource-manager/

Execute the torque and maui install script on the head node (host OS)::

    #cp /root/nukecluster/bash/setup/install_pbs-head.sh \
    /setup/.
    #chmod +x install_pbs-head.sh
    #./install_pbs-head.sh

.. Note::
	WARNING: The install_pbs-head.sh convinience script may need to be adjusted slightly.
        This script just installs the dependencies and
        executes the commands required to install Torque and Maui on the head node.

For Torque/Maui install troubleshooting see: Torque_install_ .

.. _Torque_install: http://docs.adaptivecomputing.com/torque/6-1-0/adminGuide/help.htm

Configure Torque/Maui
---------------------

Queue settings are located in: ``/var/spool/pbs/server_priv/queues/.`` by default.
The queue settings can be updated by modifying the ``qconfig`` file and
running the ``updatequeue.sh`` script included in this nukestar maintenence package.

PBS queueconfig documentation may be found here: Qconfig_.

.. _Qconfig: http://docs.adaptivecomputing.com/torque/4-0-2/Content/topics/4-serverPolicies/queueConfig.htm

Maui settings are stored in ``/var/spool/maui/maui.cfg``.  Documentation for this file may be found: Maui_docs_.

.. _Maui_docs: http://docs.adaptivecomputing.com/maui/index.php

The hostlist fo Toruqe/Maui is stored in: ``/var/spool/pbs/server_priv/nodes`` by default.  This file
must be modified to add new compute nodes to the cluster.

Chroot / Compute Node Software
+++++++++++++++++++++++++++++++

The ``PBS_MOM`` daemon provided by Torque must be installed on the compute nodes so that the ``pbs_server``
and Maui scheduler can communicate with and schedule jobs on the compute nodes.

Install PBS_MOM in Chroot / Compute Nodes
------------------------------------------

The Torque install process on the head node will create 
two important shell scripts (which are acutally binary blobs!).
Check that the following files exist::

    #cat /setup/torque-6.1.0/torque-package-clients-linux-x86_64.sh
    #cat /setup/torque-6.1.0/torque-package-mom-linux-x86_64.sh

Create a scratch directory in chroot::

    #mkdir /srv/nukeroot/setup

Copy the binary blob/torque shell scripts to the Chroot::

    #cp /setup/torque-6.1.0/torque-package-clients-linux-x86_64.sh /srv/nukeroot/setup/.
    #cp /setup/torque-6.1.0/torque-package-mom-linux-x86_64.sh /srv/nukeroot/setup/.

Chroot ::

    #chroot /srv/nukeroot

Install ``pbs_mom`` and ``trqauthd``::

    #> cd /setup
    #> chmod +x torque-package-mom-linux-x86_64.sh
    #> chmod +x torque-package-clients-linux-x86_64.sh
    #> ./torque-package-mom-linux-x86_64.sh --install
    #> ./torque-package-clients-linux-x86_64.sh --install

Startup trqauthd in the chroot::

    #>trqauthd

Check to see if it works::

    #> qnodes

``qnodes`` should output the status of all nodes in the cluster.  See the users guide for how to submit jobs to the queue.


TORQUE / MAUI systemd scripts
++++++++++++++++++++++++++++++

On the head node we must start the ``pbs_server``, ``maui``, and ``pbs_mom`` daemons.  On the compute nodes, 
only the ``pbs_mom`` service is required.  It is convinient to have these services automatically start on system boot up.
This can be achived by enabling the systemd startup scripts included with the Torque package.


Head Node
---------

After a sucessful make and install of the Torque and Maui packages
navigate to ``#/usr/lib/systemd/system/.``.

Check for the files ``pbs_server.service``, ``trqauthd.service`` in this directory

Create the Maui systemd script::

    #touch /usr/lib/systemd/system/maui.service

Fill ``/usr/lib/systemd/system/maui.service`` with the following::

	[Unit]
	Description=MAUI scheduler
	Requires=network.target local-fs.target
	Wants=rsyslog.target
	After=trqauthd.service pbs_server.service network.target local-fs.target rsyslog.target

	[Service]
	Type=forking
	User=root

	# Let systemd guess the pid.
	GuessMainPID=yes

	# Start command
	ExecStart=/usr/local/maui/sbin/maui

	[Install]
	WantedBy=multi-user.target

Enable Torque/Maui on boot with::

    #cd /usr/lib/systemd/system
    #systemctl enable trqauthd.service
    #systemctl enable pbs_server.service
    #systemctl enable maui.service

Bring up Torque/Maui ::

    #service trqauthd start
    #service pbs_server start
    #service maui start

Check the status of each service ::

    #systemctl status trqauthd.service
    #systemctl status pbs_server.service
    #systemctl status maui.service

Compute Nodes / chroot
-----------------------

After the ``torque-package-clients-linux-x86_64.sh`` and.
``torque-package-mom-linux-x86_64.sh`` scripts have been executed in the chroot environment
check that ``/usr/lib/systemd/system/pbs_mom.service`` exists in the chroot::

    #>cat /usr/lib/systemd/system/pbs_mom.service

check that ``/usr/lib/systemd/system/trqauthd.service`` exists in the chroot::

    #>cat /usr/lib/systemd/system/trqauthd.service

If this file was not created after executing ``torque-package-mom-linux-x86_64.sh`` something
went wrong with the Torque install.

Enable PBS_MOM daemon to start on compute node boot with::

    #>cd /usr/lib/systemd/system
    #>systemctl enable trqauthd.service
    #>systemctl enable pbs_mom.service

This concludes basic Torque/Maui setup.

Environment Modules
-------------------

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
