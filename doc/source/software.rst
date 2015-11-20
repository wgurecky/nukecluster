Remote Access
+++++++++++++

Nukestar can be accessed via SSH::

	$ssh <user_name>@nukestar.me.utexas.edu

Before you can connect you need to email the system admins with the following info included:

	- Your desired user name
	- A public rsa key (see next section)

Linux / OSX
-----------

If you do not already have an rsa key pair generate them::

	$ssh-keygen -t rsa

Follow the prompt on the screen.

Your new keys will be placed in ``~/.ssh/.`` on your machine.  Keep the private key safe!  The public key (had file suffix ``.pub``) should be emailed to the system admin.

Windows Clients
---------------

Use Putty or google for some other free SSH client software.  Generate public/private key pair.  email the public key to a system administrator.

Environment Modules
+++++++++++++++++++

Having many versions of gcc, cmake, openmpi ect installed and switching between them quickly can be a pain.  There is a package to ease this pain...

The Environment Modules package allows the user to manipulate environment variables.

A user can create new modules and place them in ``/usr/share/modules/modulefiles/.``

A list of currently avalible modules is given by::

	$module avail

A module can be loaded by::

	$module load <module>

And unloaded by::

	$module unload <module>

Example Environment Module
---------------------------

An example env module is provided below::

	#%Module1.0
	proc ModulesHelp { } {
	global dotversion

	puts stderr "\tSets up VERA ENV vars to run VERA-CS"
	}
	conflict veraDEV


	module-whatis "Sets the environment for running VERA-CS"

	# Tcl script vars
	set VERA_DEV_ENV_BASE /home/wlg333/vera
	set VERA_DEV_ENV_COMPILER_BASE /home/wlg333/vera/gcc-4.8.3
	set VERA_GCC_BASE_DIR /home/wlg333/vera/gcc-4.8.3/toolset/gcc-4.8.3
	set VERA_MPI_BASE_DIR /home/wlg333/vera/gcc-4.8.3/toolset/mpich-3.1.3
	set VERA_INSTALL_BASE_DIR /home/wlg333/vera/installs/2015-11-18

	set HDF5_LIB_DIR /home/wlg333/vera/gcc-4.8.3/tpls/opt/hdf5-1.8.10/lib
	set HYPRE_LIB_DIR /home/wlg333/vera/gcc-4.8.3/tpls/opt/hypre-2.9.1a/lib
	set PETSC_LIB_DIR /home/wlg333/vera/gcc-4.8.3/tpls/opt/petsc-3.5.4/lib

	# Path of PBS script helper
	prepend-path PATH /home/wlg333/vera/PBSsub

	# Set the binary dir for MPI executbles (e.g. mpirun)
	prepend-path PATH $VERA_MPI_BASE_DIR/bin

	# Set the binary dir for the installed components
	prepend-path PATH $VERA_INSTALL_BASE_DIR/bin

	# Set paths to shared libs for compiler and MPI
	prepend-path LD_LIBRARY_PATH $VERA_MPI_BASE_DIR/lib:$VERA_GCC_BASE_DIR/lib64

	# Set library path for installed commonents (in case shared libs installed)
	prepend-path LD_LIBRARY_PATH $VERA_INSTALL_BASE_DIR/lib

	# Set path to shared libs needed by MOOSE/Bison-CASL executables
	prepend-path LD_LIBRARY_PATH $PETSC_LIB_DIR:$HYPRE_LIB_DIR:$HDF5_LIB_DIR

	# Scale varaibles
	setenv SCALE $VERA_INSTALL_BASE_DIR
	setenv DATA $VERA_INSTALL_BASE_DIR/share/Insilico/test_data
	setenv MPACT_DATA $VERA_INSTALL_BASE_DIR/share/Insilico/test_data

In the above example, a conflicting module is defined.  Upon loading the above module, if the conflicting module is loaded, it will be unloaded.

User generated env modules can be placed in ``/usr/share/modules/modulefiles/.``


PBS scripts
+++++++++++

A Portable Batch System (provided by TORQUE) and resource manager (Maui) handle job scheduling on the cluster. 

To check what jobs are currently running or queued on the cluster run::

	$qstat

To check the status of the nodes in the cluster run::

	$qnodes

To submit a job to the cluster, the user must first write a PBS script.  This is essentially a bash script.  An example PBS script is given in the following section.  After writing the PBS script, the job may be submitted to the cluster with::

	$qsub <pbs_script.sh>

Documentation for writing PBS scripts can be found elsewhere on the web.  Google is your friend.

PBS Script Example
------------------

The following PBS script submits an job to cluster utilizing 24 cores on node nukestar02::

	#!/bin/sh
	### PBS Settings
	#PBS -N test_case
	#PBS -l nodes=nukestar02:ppn=24
	#PBS -q day
	#PBS -j oe
	#PBS -V

	### Display the job context
	echo "The master node of this job is: $PBS_O_HOST"
	echo "The execution host is:" `hostname`
	echo "Time is:" `date`
	echo "Directory is:" `pwd`
	NPROCS=`wc -l < $PBS_NODEFILE`
	NNODES=`uniq $PBS_NODEFILE | wc -l`
	echo "This job is using $NPROCS CPU(s) on the following $NNODES node(s):"
	echo "-----------------------"
	uniq $PBS_NODEFILE | sort
	echo "-----------------------"

	# filename of input mcnpx deck
	RUNNAME="test_p1"

	### MCNP run
	module load mcnp6
	cd ~/run/$RUNDIR
	/usr/local/bin/mpiexec -mca plm rsh \
	/usr/share/mcnp/v6/bin/mcnp6.mpi \
	i=$RUNNAME".i" \
	n=$RUNNAME"."
	### If the first line in the input file contains a
	# CONTINUE card, place a continue indicator in the 
	# mcnp run parameters

Building Software
+++++++++++++++++

You can switch between system-wide accessible gcc and openmpi versions by first running ``module avail`` to check which are installed and then loading the desired version with  ``module load <gcc-version>``.  If you need a specific version of gcc or some library you should be able to download the source to your home directory and build there.

See gcc, cmake, and env module documentation if you need help.
