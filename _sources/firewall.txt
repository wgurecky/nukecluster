Configuring The Firewall/Router
++++++++++++++++++++++++++++++++

Configure the WAN and LAN interfaces during the initial install procedure.
Ensure a DHCP server is running on the LAN interface.  The internal network should be
setup assign IPs by default on 192.168.1.xxx/255.255.255.0 subnet.  The default IP of the LAN interface
should be 192.168.1.1.  The web configuration may be accessed at this address from the internal
network.  From the head node, type in this IP address into the web browsers URL field to do so.

The system administrator must gather all MAC addresses for all computers in the
cluster. The easiest way to do this is just to power on every computer in the cluster.  Under the 
"DHCP server" tab in the web configurator there should be information on the current DHCP leases.
This list will contain the IP addresses and MAC addresses of all computers that are currently on
the LAN network.  The easiest way to ensure the compute nodes are assigned hostnames in a physically 
meaningful way is to power on each node in the cluster one-by-one, making note of it's physical location
and assigning an IP and hostname in an organized manner.

Static IP's may be assigned to all nodes in the cluster under the DHCP/LAN tab in the firewall
web-configurator once the MAC addresses of the machines are known.  Assigning each machine a static IP on
the LAN is essential to ensure that PXE booting, NFS filesystem sharing, and Torque-Maui operate properly.

NAT
----

Stands for Network address Translation.  Under the "NAT" tab, configure WAN port 22 to be forwarded to the Head node.
A new firewall rule will be created.  One that allows all outside traffic targeted at port 22
to the head node port 22.  Port 22 is the default port that the ssh-server daemon listens on.

Allow PXE booting
------------------

In the DHCP server configuration tab ensure you enable network booting!  This is critical for the diskless clients to retrieve
the boot image from the head node at startup.  Check the TFTP server box.  Enable network booting.
For the server address put the head node's IP address ``192.168.1.101`` and for the filename put ``pxelinux.0``.

.. note::
    This is VERY important!

Other Software
---------------

The default install of PfSense is quite secure.  The default firewall rules (+ the NAT rule) will work for most situations.  
Many packages are available that improve the monitoring capabilities of PfSense.  The admin should consider installing
PFblocker and Snort.  PFblocker allows the admin to easily block IPs from specific countries.  It is recommended to block all of
Africa, Asia + Russia, and South America.  Snort is an intrusion detection package.  You can download "rules" from <website here>
to filter and log specific traffic.
