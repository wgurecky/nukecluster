#!/bin/bash

QDIR=/var/spool/pbs/server_priv/queues
QLIST="default quick day week month extended james will"

echo Deleting old queues
for x in $QLIST
do
	rm $QDIR/$x
done

echo Shutting down Torque
qterm
killall pbs_server


echo Restarting Torque
pbs_server

echo Piping queue information to Torque Server
cat qconfig | qmgr


for x in $QLIST
do
	if [ ! -f $QDIR/$x ]; then
	  echo Did not find queue $x in server settings, something may be wrong
	  exit 1
	fi
done

echo Success
exit 0
