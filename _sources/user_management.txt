User and Group Management
+++++++++++++++++++++++++

Cluster user permissions, ssh keys, and UID's/GID's must be managed in a very
organized way to prevent any strange permissions or connections issues down the road.
To facilitate easy user management, Ansible_ playbooks are provided in the repo.  Specifically,
in the /roles/common directory.  The idea is to ensure UID's, groups, and ssh keys are consistent
between the host OS and the chroot environment.

Ansible_ can be installed by apt-get::

   #apt-get update && apt-get install ansible

.. _Ansible: http://docs.ansible.com

Ansible's only dependency is ssh.  Ansible is a radically simple IT automation engine that is well suited for configuration management and application deployment.

Ansible scripts included with this repository should be in ``/root/nukecluster``.
From a fresh install the usermod play can be obtained via git::

    #cd /root
    #git clone https://github.com/wgurecky/nukecluster.git

The primary yml file used for user and group management is: ``roles/common/vars/main.yml``.  This file should be kept up to date
at all times.  If you want to add a user, group, or add a user to a particular group then it is highly recommended to USE THIS FILE to do so.  As a bonus, it is easy to keep track of all the users and groups (rather than relying on unix commands, which could get burdensome if ~30 users with many groups are all floating around) on the system in one tidy file. It is desirable to create a symlink to this file in an easily accessible path like::

    #ln -s /root/nukecluster/roles/common/vars/main.yml /root/nukecluster/usr_settings.yml

This file contains user and group settings :

.. code-block:: yaml

	ssh_users:
	  - name: wlg333
	    groups: users,mcnpx,vera-admin,mcnp6,njoy,serpent,origin,sudo
	    shell: /bin/bash
	    uid: 1010

	  - name: armstru
	    groups: users,mcnpx
	    shell: /bin/bash
	    uid: 1011

	  - name: dbz473
	    groups: users
	    shell: /bin/bash
	    uid: 1012

	  - name: rf8465
	    groups: users,mcnpx,mcnp6,origin,njoy,serpent,sudo
	    shell: /bin/bash
	    uid: 1013

	  - name: admin
	    groups: mcnpx,mcnp6,origin,njoy,serpent,sudo
	    shell: /bin/bash
	    uid: 1014

	# List of groups.  Add or remove groups from the cluster here.
	cluster_groups: 
	  - name: vera-admin
	    gid:  2101
	  - name: mcnpx
	    gid:  2102
	  - name: mcnp6
	    gid:  2103
	  - name: origin
	    gid:  2104
	  - name: njoy
	    gid:  2105
	  - name: serpent
	    gid:  2106
	  - name: users
	    gid:  2100
	  - name: sudo
	    gid:  2000

        # dummy variable used for temp key storage
	keys_dir:  /root/nukecluster/roles/common/files

.. Note::

    This file is syntax sensitive.  Abide by yml syntax and mind whitespace.
    Indentation must be perfect (use spaces only).

When this user settings file is modified the next step is to run the usermod.yml playbook (idiomatically "usermod play") in the base directory of this repo::

    #ansible-playbook usermod.yml

By default, the usermod.yml top level script will run all user, group, and ssh commands required.  

.. Note:: 
    You must be logged into the root account (or use sudo) to run the usermod play.

Adding New Users to Cluster
---------------------------

When a new user wants remote access to the cluster:

1. Request a rsa public key from the prospective new user.
2. Add that rsa pub key to his ``/home/<his_username>/.ssh/foreign_keys`` file. Create this file if it does not already exist.
3. Add his username (and groups, preferred shell & uid) to the users and groups settings file (``usr_settings.yml``) as shown above.  Don't forget to assign the new user a unique UID.
4. Run the usermod play.

.. Note::
	By default, the usermod play looks for a ``foreign_keys`` file in the ``/home/<user>/.ssh/.`` folder of each user when run.  Keys in this file are appended to the ``authorized_keys`` file for that user.  This is done to try to keep externally generated keys seperate from internally generated keys.

Manipulating Groups and Permissions
------------------------------------

- Edit the ``/root/nukecluster/roles/common/vars/main.yml`` file to reflect new groups and permissions.

.. Note::

    Ensure to follow yml syntax.  Also make sure to remember unique GID (group IDs) and UID (User IDs).

- Run the usermod.yml play.::

    #cd /root/nukecluster
    #ansible-playbook usermod.yml

Enabling Auto SSH Chroot on login
---------------------------------

On the base system, edit ``/etc/ssh/sshd_config``.  At the end of this file, add ::

    Match group users
        ChrootDirectory /srv/nukeroot
        AllowX11Forwarding yes

Restart sshd ::

    #/etc/init.d/ssh restart

When users in the ``users`` group ssh into the cluster, they will immediately be relegated to
the Chroot environment, where all the compute software lives.  Non-admins essentially never see the
host operating system.  It is imperative that the admin account is not a member of the ``users`` group
so that when the admin remotely logs in, he has access to the base OS AND the chroot.  There is no good
way to break out of the chroot once you are placed inside by sshd.


Securing sshd
-------------

On the base OS: in the ``/etc/ssh/sshd_config`` file ensure that cleer text passwords
are disabled with the following two lines::

    PasswordAuthentication no
    PermitEmptyPasswords no

Also disable password based root login with::

    PermitRootLogin without-password 

.. Note::

    This sounds scary but according to the documentation this setting ONLY allows
    root login via SSH key.  NEVER place any pub ssh key from ANY computer outside of the
    nukestar LAN inside the root authorized_keys file!
    
If any changes were made, restart sshd ::

    #/etc/init.d/ssh restart
