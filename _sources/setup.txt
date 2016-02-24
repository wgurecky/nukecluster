Setup and Install
=================

The purpose of each machine in the cluster is provided below:

Firewall/Router
+++++++++++++++

Purpose:
  * Runs DHCP server, assigns IP addresses to all nodes in the cluster on the local subnet
  * Routes incoming SSH traffic to port 22 on the head node (NAT)
  * Limits the attack surface of the cluster to just ONE open port
  * Obscures the presence of the cluster on the net (inhibit, but not prevent portscans)
  * Logs traffic information

Firewall hardware requirements:
  * 2 port 1 Gbit/sec NIC (intel preferred)
  * Modest CPU  (2 core 2GHZ+)
  * Atleast 1 GB RAM

Head Node
++++++++++

Role:
  * Runs PBS-server and maui to distribute jobs to compute nodes
  * Raid-10 for fault tolorance operation. (>=4 2TB HDDs)
  * Runs NFS share
  * Contains a chroot of the compute node OS
  * Runs TFTP-server to distribute OS images to compute nodes on compute node bootup
  * Is the single point of entry to the cluster via ssh

Head node hardware requirements:
  * Large RAM pool (>=16 GB)
  * Fast CPU (8 core + Intel recommended)

The head node should have a VGA port so that a monitor can be connected to it.  
This will ease some administrative tasks.


Compute Nodes
++++++++++++++
All large MPI tasks will be run on the compute nodes.  The PBS+maui queuing
system ensures fair utilization of the cluster's resources.

Role:
  * provides computational power 
  * runs pbs_mom 

Hardware:
  * many core
  * >= 1Gbit ethernet NiCs
  * atleast 2GB RAM/core

Storage Nodes (OPTIONAL)
++++++++++++++++++++++++

Role:
  * Contains storage pool(s) used as a glusterFS brick(s)
  * Runs GlusterFS-server
  * Runs NFS-server
  * Provides location to back up the Head Node's FS.

Storage node hardware:
  * Atleast 5 hard disks.  1 for OS, 4 for glusterfs/raid
  * Large RAM pool (>=16 GB)
  * Disks used for mass storage should be SAS 1TB+ 7200, or 10000 RPM drives
  * multi-core (4+ cores)

Other
+++++
Network Switches:
  * at the time of this writing, dont know if ethernet or infiniband
  * provides interconnectivity between all nodes in cluster
  * Should be atleast 1Gbit/sec 

OS Installs
+++++++++++++++++

The operating system of choice for the cluster was chosen to be 
Debian_ Jessie.  The authors are familiar with Debian based machines from
past experience.  

.. _Debian: http://www.debian.org

PfSense_ was chosen as a firewall OS since it is easy to configure and install.  In addition there are many
packages available for PfSense that increase it's utility and security.

.. _PfSense: https://www.pfsense.org

