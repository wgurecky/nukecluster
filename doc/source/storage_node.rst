Configure Storage Nodes
+++++++++++++++++++++++

If seperate storage are desired; configuring cluster storage precedes configuing the head node or the 
compute nodes.  This storage node configuratin guide assumes that the storage nodes already have a
clean Debian installation on them.

Here we will assume we have 4 storage nodes and each node has 1 drive dedicated to the OS install and 2 drives available for both a
home and a root glusterFS brick (5 drives total).  Of course, depending on hardware the final setup may change.

Setup RAID on Each Storage Node
-------------------------------

create a single empty primary partition the target glusterFS disks ::
    
    fdisk /dev/sdb
    fdisk /dev/sdc
    fdisk /dev/sdd
    fdisk /dev/sde
    
Setup RAID(s) ::

    mdadm --create --verbose /dev/md0 --level=mirror --raid-devices=2 /dev/sdb1 /dev/sdc1
    mdadm --create --verbose /dev/md1 --level=mirror --raid-devices=2 /dev/sdd1 /dev/sde1

create ext4 filesystem(s) ::

    mkfs.ext4 /dev/md0
    mkfs.ext4 /dev/md1

create glusterfs dir ::

    mkdir /glusterfs
    mkdir /glusterfs/nukeroot
    mkdir /glusterfs/nukehome

mount newly created ext4 fs to the above dirs.  Add the following to /etc/fstab ::

    /dev/md0 /glusterfs/nukeroot ext4 defaults,noatime 0 0
    /dev/md1 /glusterfs/nukehome ext4 defaults,noatime 0 0

run ::

    mount -a

Ensure that ``/etc/hosts`` contains hostnames and IPs of other storage and compute nodes.

Setup GlusterFS on Each Storage Node
------------------------------------

Install glusterFS. ::

    wget -O - http://download.gluster.org/pub/gluster/glusterfs/3.5/3.5.1/Debian/pubkey.gpg | apt-key add -
    echo deb http://download.gluster.org/pub/gluster/glusterfs/3.5/3.5.1/Debian/apt wheezy main >  \
                  /etc/apt/sources.list.d/gluster.list
    apt-get update
    apt-get install glusterfs-server

Configure glusterFS::

    gluster peer probe <hostnames of OTHER storage nodes>

When the above tasks have been completed on ALL storage nodes run:

Create glusterFS file system(s).  This step only needs to be performed on one of the storage nodes. ::

    gluster volume create nukeroot replica 2 stor01:/glusterfs/nukeroot stor02:/glusterfs/nukeroot stor03:/glusterfs/nukeroot stor04:/glusterfs/nukeroot
    gluster volume create nukehome replica 2 stor01:/glusterfs/nukehome stor02:/glusterfs/nukehome stor03:/glusterfs/nukehome stor04:/glusterfs/nukehome

Finish glusterFS install ::

    gluster volume info
    gluster volume start nukeroot
    gluster volume start nukehome

Export GlusterFS as NFS share
-----------------------------

See documentation at www.gluster.org
