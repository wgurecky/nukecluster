Base Software 
+++++++++++++

The software install guide is split between the host OS (base system) and the chroot environment
which is effectively the global "compute node" OS.

On the base system we will install:

- Torque+maui job scheduler

In the chroot / compute node environment, the following software will be installed:

- Torque (pbs_mom) 
- gcc compilers
- intel compiler (optional)
- openmpi
- environment-modules
- user specific software ::

  - mcnp
  - python packages
  - njoy
  - openmc
  - starccm+
  - ect...

Base OS software
-----------------

Install scripts for Torque / maui can be found in the /bash folder of this repo.  

Chroot / Compute Node Software
-------------------------------

Install the environment-modules package in chroot::  

    #chroot /srv/nukeroot
    #>apt-get install environment-modules

run::

    $>add.modules

For every user that wants to use environment-modules.

Then update the contents of ~/.bashrc.  Uncomment the line ::

   module() { eval `/usr/bin/modulecmd $module_shell $*`; }

and comment out any other ``module()`` definition.


TORQUE / MAUI systemd scripts
-----------------------------

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
