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

Instal scripts for Torque / maui can be found in the /bash folder of this repo.  

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
