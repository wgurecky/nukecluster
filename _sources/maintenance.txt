
Hardware Maintainance Guide
+++++++++++++++++++++++++++

The following is a collection of common maintenance tasks.

Head Node Hard Drive Replacement
--------------------------------

The hard drives in the head node are in a raid10 configuration.

This way if one drive in the array is lost all the data stored on that raid array
is still valid.  Though this provides some resilience to hardware failure it is
not a reason to ignore keeping a proper backup.  See the section on cron job automated
backups.

.. Note::

    Recall all commands preceeded by a # sign are executed as root.  Make sure you are in
    the `base` OS not in the chroot before proceeding.

To check the health of the raid array execute::

    #cat /proc/mdstat

You will see an output similar to::

    Personalities : [raid10]
    md0 : active raid10 sda1[0] sdb1[1] sdc1[2] sdd1[3]
    3906765800 blocks super 1.2 512K chunks 2 near-copies [4/4][UUUU]
    unused devices: <none>

If anything is wrong with a drive
it will be marked ``failed`` or ``down`` with the ``_`` symbol like this::

    [_UUU]

In our example the device ``/dev/sda`` has failed.

Information on which device has failed should also be provided.  The admin needs to know
the serial number of the failed device so the correct drive can be identified and swapped out for a new one.

Device ``/dev/sda1`` has failed so the admin should run::

    #hdparm -i /dev/sda

Which will output the serial number and manufacture information of the drive.

After the bad drive has been identified, it is time to mark it as a failed device::

    #mdadm --manage /dev/md0 --fail /dev/sda1
    #mdadm --manage /dev/md0 --remove /dev/sda1

Next, safely shutdown the machine::

    #shutdown -P now

Then replace the broken drive with a new drive.

.. Note::

    The head node currently uses 2TB WD black drives.  Technically any 2TB hard disk will
    work but it is recommended to replace the failed drive with a similar make and model.

After powering the machine back on, the partition table from a functioning disk must be copied over
to the new drive::

    #sfdisk -d /dev/sdb | sfdisk /dev/sda

Now add the new device to the array::

    #mdadm --manage /dev/md0 --add /dev/sda1

Check the array is being rebuilt::

    #cat /proc/mdstat

Should output that the array is being rebuilt.  It could take a few hours to complete the process.  The cluster
will be functional during this time with reduced IO performance.

Rebooting a Compute Node
------------------------

Compute nodes may go down from time to time or need to be rebooted after a utility power failure.

Though this should be pretty self evident... To reboot a compute node make sure the head node is powered on first.  Remember to
to select ``PXE Boot`` (``<F12>``) in the BIOS of the compute node.

For more boot options see the dell poweredge r815_ manual.

.. _r815:  https://www.dell.com/support/home/us/en/04/product-support/product/poweredge-r815/manuals


Backup Backup Backup
+++++++++++++++++++++

User data (data residing in the ``/home/srv/nukehome``) directory must be backed up!  No excuses.

Data is backed up to a USB connected 1TB hard disk.  The backup disk is encrypted with LUKS (Linux Unified Key Setup) to prevent physical theft of data.
To manually decrypt and mount the drive::

    #cryptdisk_start nuke_backup
    #mount -a

Alternatively::

    #cryptsetup luksOpen /dev/sde1 encrypted_home_backup
    #mount /dev/mapper/encrypted_home_backup /mnt/backup

The luksOpen command will prompt for a password.

Normally, the encrypted device will be mounted to the head node on boot.  To accomplish automated mounting of an
encrypted volume, the contents of ``/etc/crypttab`` are::

    nuke_backup /dev/disk/by-uuid/<UUID_of_device> /root/keyfile luks

.. Note::

    Notice the /root/keyfile entry.  Following sections cover how to generate a keyfile to automate
    mounting a LUKS encrypted volume.

.. Note::

    If the backup device is ever changed ensure to 1) encrypt it with LUKS and 2) change the device name in
    /etc/crypttab

And the corresponding line in ``/etc/fstab`` ::

    /dev/mapper/nuke_backup /mnt/backup ext4 defaults 0 2

Cron Job
--------

A backup cron_ job has been added to the root's ``crontab``.  The admin can edit the crontab via::

    #crontab -e

Setting up a weekly ``/home/srv/nukehome`` incremental backup job is simple.  It makes use of rsync_ .  The crontab entry
looks like::

    0 0 * * 0 /root/nukecluster/bash/backupHome.sh

The backup script (included in this repo) will only run if the USB backup device is plugged into the head node!

.. _rsync: http://rsync.samba.org
.. _cron: https://wiki.archlinux.org/index.php/Cron

Encrypting a Device
-------------------

LUKS encryption can be applied to a new backup device with::

    #cryptsetup -y -v luksFormat /dev/<device_name>

Will prompt for a password.  Then run::

    #cryptsetup luksOpen /dev/<device_name> new_device
    #mkfs.ext4 /dev/mapper/new_device

This will erase all data on the device.

Creating a root keyfile
------------------------

A keyfile is necessary to automate the process of unlocking LUKS volumes on boot.

Gen some random 4096 bit junk::

    #dd if=/dev/urandom of=/root/keyfile bs=1024 count=4

Make it read only by root::

    #chmod 0400 /root/keyfile

Add keyfile to LUKS volume::

    #cryptsetup luksAddKey /dev/disk/by-uuid/<UUID_of_device> /root/keyfile

