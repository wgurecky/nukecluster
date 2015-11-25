User and Group Management
+++++++++++++++++++++++++

Cluster user permissions, ssh keys, and UID's/GID's must be managed in a very
organized way to prevent any strange permissions or connections issues down the road.
To facilitate easy user management, Ansible playbooks are provided in the repo.  Specifically,
in the /roles/common directory.  The idea is to ensure UID's, groups, and ssh keys are consistant
between the host OS and the chroot environment.

Ansible can be installed by apt-get::

   #apt-get update && apt-get install ansible

Ansible's only dependency is ssh.

The primary yml file used for user and group management is: ``roles/common/vars/main.yml``.  This file should be kept up to date
at all times.  If you want to add a user, group, or add a user to a particular group then it is highly recommended to USE THIS FILE to do so.  As a bounous, it is easy to keep track of all the users and groups (rather than relying on unix commands, which could get burdensome if ~30 users with many groups are all floating around) on the system in one tidy file. It may be desirable to create a symlink to this file in an easily accessible path like::

    ln -s /home/root/nukecluster/roles/common/vars/main.yml /home/root/nukecluster/usr_settings.yml

This file contains user and group settings::

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

    This file is syntax sensitive.  Abide by yml syntax and mind whitespace.  Lists are comma seperated, no spaces
    indentation must be perfect. spaces only.

When this user settings file is modified the next step is to run the usermod.yml playbood (idiomatically "usermod play") in the base directory of this repo::

    #ansible-playbook usermod.yml

By default, the usermod.yml top level script will run all user, group, and ssh commands required.  Note: you must be logged into the root account to run the usermod play.

Note on External SSH Keys
--------------------------

By default, the usermod play looks for a ``foreign_keys`` file in the ``/home/<user>/.ssh/.`` folder of each user when run.  Keys in this file are appended to the ``authorized_keys`` file for that user.  This is done to try to keep externally generated keys seperate from internally generated keys.

When a new user wants remote access to the cluster. 1) request an rsa public key from him.  2) add that rsa pub key to his ``/home/<his_username>/.ssh/foreign_keys`` file. 3) add his username (and groups, prefered shell & uid) to the users and groups settings file as shown above. 4) Run the usermod play.

Enabling Auto SSH Chroot on login
---------------------------------

On the base system, edit ``/etc/ssh/sshd_config``.  At the end of this file, add ::

    Match group users
        ChrootDirectory /srv/nukeroot
        AllowX11Forwarding yes

Restart sshd ::

    #/etc/init.d/ssh restart

When users in the ``users`` group ssh into the cluster, they will imediately be relegated to
the Chroot environment, where all the compute software lives.  Non-admins essentially never see the
host operating system.  It is imparitive that the admin account is not a member of the ``users`` group
so that when the admin remotely logs in, he has access to the base OS AND the chroot.  There is no good
way to break out of the chroot once you are placed inside by sshd.
