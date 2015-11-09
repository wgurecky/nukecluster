Setup and Install
=================

The pourpose of each machine in the cluster is provided below:

Firewall/Router
+++++++++++++++

Purpose:
  * Runs DHCP server, assigns IP adresses to all nodes in the cluster
  * Routes incomming SSH traffic to port 22 on the head node (NAT)
  * Limits the attack surface of the cluster to just ONE open port
  * Obscures the presence of the cluster on the net (inhibit portscans)
  * Logs traffic information

Firewall hardware requirements:
  * 2 port 1 Gbit/sec NIC (intel prefered)
  * Modest CPU  (2 core 2GHZ+)
  * Atleast 1 GB RAM

Head Node
++++++++++

Role:
  * Runs PBS-server and maui to distribute jobs to compute nodes
  * Raid-10 for fault tolorance operation. (>=4 2TB HDDs)
  * Runs NFS share
  * Contains a chroot upon which the compute node images are built 
  * Runs PXE-server to distribute OS images to compute nodes on compute node bootup
  * Is the single point of entry to the cluster via ssh

Head node hardware requirements:
  * Large RAM pool (>=16 GB)
  * Fast CPU (8 core + Intel recommended)

The head node should have a VGA port so that a monitor can be connected to it.  
This will ease some administrative tasks.

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

Other
+++++
Network Switches:
  * at the time of this writting, dont know if ethernet or infiniband
  * provides interconnectivity between all nodes in cluster
  * Should be atleast 1Gbit/sec 

Aprox Maximum Hardware Cost
+++++++++++++++++++++++++++

Not including any of the bare bones computers (we got all the compute nodes for free?):
  * $200/1TB SAS disk  x 16 = $ 3200  for hard drives
  * $100 for ethernet cables
  * $2400 per 24 port infiniband switch x 2 = $4800  (optional)
  * $1000 for 48 infiniband cables (optional)
  * $600 per DELL infiniband PCI card x 5 = $3000 (optional)

Approx $14200 can be spent for an optimal setup, not including cost of computational power.

.. Note::
    The old Nukestar nodes are suitable for use as compute / storage nodes in the new cluster...
    However, the old nodes lack an Infiniband interface.  It is very expensive to upgrade the old
    machines to be infiniband compatible.

Operating System
+++++++++++++++++
The operating system of choice for the cluster was chosen to be 
Debian Jessie.  The authors are familiar with Debian based machines from
past experience.

OS Install
-----------

The first task is to install the necissary operating systems on the firewall,
head node (and optionally the storage nodes).  PfSense should be installed on the Firewall.

Debian is installed on the Head node. Visit their respective websites to download bootable install isos or if
you run into issues installing either.

When installing Debian on the head node, 
take care to configure the raid 10 correctly, utilizing all drives in a single mdraid storage pool.
A recommended raid 10 + LVM setup is shown below.  Logical Volume Management (LVM) is useful
when creating backup snapshots or resizing partitions online.::

    -------------------------------------------------------------
    |                       RAID 10 Array                       |
    | Disk 1 (sda) | Disk 2 (sdb) | Disk 3 (sdc) | Disk 4 (sdd) | <- config each divice as RAID device
    -------------------------------------------------------------
    |                           LVM                             | <- Use entire raid10 in LVM pool
    -------------------------------------------------------------
    | LVM locigal vol "home"            | LVM logical vol "root"| <- LVM logical volumes
    -------------------------------------------------------------
    |          /home   (~1.5Tb)         |           / (~0.5Tb)  | <- fs mounts
    -------------------------------------------------------------

.. Note::

    Ensure to mark _atleast_ one disk with a "bootable" flag durring the partitioning step.
    As of the time of this writing (fall 2015) grub can boot from the /boot directory located 
    inside a raid 10 array.  No need to make a seperate /boot partition.

The Debian installations will ask
for a new user to be setup  (in addition to the root account).  This user should be the default
system administration account.  

.. Note::
    The administrators account is NOT the root account.  We will dissallow root login from the 
    outside world to the cluster in future steps.  When first logging in as an admin 
    you must switch users to the root account to make modifications
    to the base system.  Installing sudo and adding admin users to the sudo group aliviates some
    minor annoyances of having to type "su" all the time.

Durring the install procedure, there will be an option to install some software packages.  They are
all optional, however, it is recommended to install the ssh package and disable any "printer" packages.
It is not neccisary to install a graphical desktop environment - it will only consume hard drive space but has no
other consequences.  

From here on, every command that is
executed as root will have a ``#`` symbol preceeding it.  Every command that is executed
by a limited privilage account will be preceeded by a ``$``.

If no graphical desktop environment package was selected durring the initial instal, you can choose to install a minimal
gui desktop environment after you boot the new head node OS for the first time.
X11, a basic web browser such as Madori and a simple destop environment should be installed on the head node. ::

    # apt-get update
    # apt-get install Xorg madori dwm

If dwm is installed, the contensts of ``$~/.xinitrc`` should contain. ::

    exec dwm &

The graphical environment is lauched by ::
    
    $startx

This will allow easy graphical configuration of the Firewall in the following steps. Avoid running X11 as root. The
user should learn the basic commands of dwm before use.  Dwm is a minimal desktop window manager.  Read Dwm's documentation
for details on how to resize windows, open a terminal (super + enter), or launch applications (super + p or super + space by default).

.. note::
    It is not known at this time if infiniband will be useded for interconnects or not.  It may be very expensive
    to buy the networking equipment to do so.  IF you are so lucky to have infiniband interconnects you should install
    IPoIB (IP over Infiniband) on the head node and storage nodes.  This will allow the infiniband LAN to
    be managed just like an ethernet network.
