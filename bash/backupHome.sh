#!/bin/bash

# perform backup if backup device is mounted

# check if device is mounted:

CHECK_BACK_MOUNT=/mnt/backup/iam_here

if [ -e "$CHECK_BACK_MOUNT" ]; then
	rsync -av /home/srv/nukehome /mnt/backup --delete
fi
