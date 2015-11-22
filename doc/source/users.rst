Remote Access
+++++++++++++

Nukestar can be accessed via SSH_::

    $ssh <user_name>@nukestar.me.utexas.edu

.. _SSH: http://www.openssh.com/

Before you can connect you need to email the system admins with the following info included:

    - Your desired user name
    - A public rsa key (see next section)

Linux / OSX
-----------

If you do not already have an rsa key pair generate them::

    $ssh-keygen -t rsa

Follow the prompt on the screen.

Your new keys will be placed in ``~/.ssh/.`` on your machine. Keep the private key safe! The public key (had file suffix .pub) should be emailed to the system admin.

Windows Clients
---------------

It is recommended to use PuTTY_ (freely avalible) to generate a public/private key pair. email the public key to a system administrator.

.. _PuTTY: http://www.putty.org/

Dealing with “broken pipes”
---------------------------

A SSH connection will not survive an extended network interuption due to intermittent connectivity (perhaps iffy wifi). You may recive the error message broken pipe if this occures. Worse, if you happened to be running, say, your awesome post-processing utility when this happens the program may terminate before it is done and you would have to start all over again. To avoid such a catastrophe, it is advisable to use screen or tmux to ensure you SSH session survives interuptions in your connection to nukestar.

To use screen::

    $screen -S <session_name>

It is a good idea to do the above fist-thing when connecting to nukestar.

pressing ``ctrl+a, d`` detatches from the current session.

You can recover a screen session by first listing your running sessions::

    $screen -list

And re-attaching to the desired sessoin with::

    $screen -R <session_name>

Data transfer to/from Nukestar
------------------------------

Transfering data to and from nukestar can be done with a utility called scp_ (secure copy protocall). You will need to install scp on your local machine if you want to use it. There are alternatives: Filezilla_ is a GUI program that can proform the same function as scp.

.. _scp: http://linux.die.net/man/1/scp
.. _Filezilla: http://filezilla-project.org

If you want to push data from your local machine to nukestar::

    $scp /path/to/data/file/on/your/local/machine.txt  <user_name>@nukestar.me.utexas.edu:~/destination/path/.

If you want to pull data from nukestar to your local machine::

    $scp <user_name>@nukestar.me.utexas.edu:~/path/file.txt  /path/on/local/machine/file.txt

To pull/push and entire folder you need to use the -r flag::

    $scp -r <username>@nukestar.me.utexas.edu:<source_folder> <destination_folder>

If transfering many small data or text files it may be much faster to use a utility called rsync_ (which should be avalible on any linux or OSX install. An example syntax for pulling an entire folder from nukestar to your local machine using rsync is given bellow::

    $rsync -avze ssh <user_name>@nukestar.me.utexas.edu:~/path/to/data  <destination_path> --progress

.. _rsync: http://rsync.samba.org

Visualizing Results
-------------------

To use a GUI program through an SSH connection (such as MCNP’s plotter) you need to enable Xforwarding on your SSH session. When connecting to nukestar with SSH add an aditional argument as follows::

    $ssh -X <user_name>@nukestar.me.utexas.edu

.. Note::
    Windows users will need to install Xorg on their local machine. The freely avalible Cygwin package contains Xorg for windows.

Environment Modules
+++++++++++++++++++

Having many versions of gcc, cmake, openmpi ect installed and switching between them quickly can be a pain. There is a package to ease this pain...

The Environment Modules package allows the user to manipulate environment variables.

A user can create new modules and place them in /usr/share/modules/modulefiles/.

A list of currently avalible modules is given by::

    $module avail

A module can be loaded by::

    $module load <module>

And unloaded by::

    $module unload <module>

The advantages of using module files rather than using ``~/.bashrc ~/.bash_profile`` may not be immediately clear.
It is only when you are juggling many different programs and compilers that you will find writing module files
(and perhaps utilizing them by loading them inside PBS scripts) to be a superior solution.

Example Environment Module
--------------------------

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

In the above example, a conflicting module is defined. Upon loading the above module, if the conflicting module is loaded, it will be unloaded.

User generated env modules can be placed in ``/usr/share/modules/modulefiles/.``

Submitting Jobs
+++++++++++++++

Large multi-core compute tasks (MPI or multi-threaded programs like MCNP, SERPENT, VERA ect...) can take advantage of the over 250+ cores avalible in the cluster. To ensure that the cores are being utilized efficiently and fairly (if many users want to start jobs at the same time) a job scheduler is present on the cluster. To submit multi-core jobs the user must first construct a PBS script. The PBS script contains info about the number of cores and number compute nodes to use for the calculation.

Small compute tasks can be executed on the head node without going through the extra step of constructing and submitting a PBS script. Examples of small tasks that do not need a PBS script include: A few NJOY runs, a simple single core post processing script, visualizing results, or compiling a small program.

PBS scripts
------------

A Portable Batch System (provided by TORQUE_) and resource manager (Maui_) handle job scheduling on the cluster.

.. _Maui: http://www.adaptivecomputing.com/products/open-source/maui/
.. _TORQUE: http://www.adaptivecomputing.com/products/open-source/torque-resource-manager/

To check what jobs are currently running or queued on the cluster run::

    $qstat

To check the status of the nodes in the cluster run::

    $qnodes

To submit a job to the cluster, the user must first write a PBS script. This is essentially a bash script. An example PBS script is given in the following section. After writing the PBS script, the job may be submitted to the cluster with::

    $qsub <pbs_script.sh>

To kill a job, first identify the ID of the job you want to kill with ``qstat`` then::

    $qdel <jobID>

Documentation for writing PBS scripts can be found on the the AdaptiveComputing_ website.

.. _AdaptiveComputing: http://docs.adaptivecomputing.com/torque/4-0-2/Content/topics/commands/qsub.htm


PBS Script Example
------------------

The following PBS script submits an job to cluster utilizing 24 cores on node nukestar02::

    #!/bin/bash
    ### PBS Settings
    #PBS -S /bin/bash
    #PBS -N test_case
    #PBS -l nodes=nukestar02:ppn=24
    #PBS -q day
    #PBS -j oe
    #PBS -V

    cd $PBS_O_WORKDIR

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

.. Note::
    The the ``#PBS -S /bin/bash`` line is required if you want to use env vars set in your ``~/.bashrc`` or ``~/.bash_profile``.
    In this case, it was necissary in order to load the mcnp6 module file via: ``module load mcnp6``.

.. Note::
    When submitting jobs keep in mind you cannot request more cores on a node than the node physically has.
    The number of cores per node is given bellow:
       - nukestar01:  2
       - nukestar02:  24
       - nukestar03:  24
       - nukestar04:  32
       - nukestar05:  64
       - nukestar06:  64
    If you request more cores than a node has you job will hang in the queue indefinately.
 

Building Software
+++++++++++++++++

You can switch between system-wide accessible gcc and openmpi versions by first running ``module avail`` to check which are installed and then loading the desired version with ``module load <gcc-version>``. If you need a specific version of gcc or some library you should be able to download the source to your home directory and build it there.

You can check which version of gcc, or mpicc you are using with::

    $which gcc
    $gcc --version
    $which mpicc
    $mpicc --version
    $mpiexec --version

See the gcc_, make_, and cmake_ documentation if you need help.

.. _gcc: https://gcc.gnu.org/onlinedocs/
.. _cmake: https://cmake.org/
.. _make: https://www.gnu.org/software/make/manual/make.html

If the program to be compiled is exceptionally large, requires large compile time, and can take advantage of parallel compiliation: up to 4 cores on the head node when compiling the program. Typically use the -j argument of make/cmake as follows to set the number of cores to be used when compiling::

    make -j4 <other args>

Avalible Software
+++++++++++++++++

The following packages are already installed on Nukestar:

    * MCNP6_: Monte Carlo Particle Transport  \*(Requires personal RSICC license to be presented to sys admins before use)
    * openMC_: Monte Carlo Neutron Transport
    * VERA_: The Virtual Environment for Reactor Analysis \*(Requires proof of ORNL / RSICC license)
        - MPACT:  Method of characteristic deterministic transport with built in depletion capability
        - COBRA-TF:  Nodal thermal hydraulics
        - Insilico:  Sn transport
    * NJOY: Cross section processing  \*(Requires proof of RSICC license)
    * SCALE6.1_:
        - origen: Burn-up and Depletion
        - origen-arp:  simple burn-up and depletion (no gui)
        - KENOVI: Monte Carlo Neutron Transport
    * openFOAM_: General PDE c++ toolkit useful for CFD
    * startCCM+: CFD software \*(Limited License, ask system admins for acess)
    * Python3.2 and Packages:
        - Numpy_: Linear algebra library
        - Scipy_: Scientific and numerical routine library.
        - matplotlib_:  General plotting library
        - mpi4py:  MPI library for python
        - h5py_:  HDF5 library for python
        - tables
    * Python2.7 and Pacakges:
        - Numpy
        - Scipy
        - matplotlib:  General plotting library
        - PYNE_:  Nuclear engineering python toolkit
        - h5py
        - mpi4py:  MPI library for python
        - tables
        - fipy:  Finite volume PDE library

.. _openFOAM: http://www.openfoam.org
.. _PYNE: http://pyne.io
.. _SCALE6.1: http://scale.ornl.gov
.. _MCNP6: https://mcnp.lanl.gov
.. _VERA:  http://www.casl.gov/vera.shtml
.. _openMC: https://mit-crpg.github.io/openmc/
.. _Scipy: http://www.scipy.org
.. _Numpy: http://www.numpy.org
.. _matplotlib: http://matplotlib.org
.. _h5py: http://pythonhosted.org/mpi4py/

This list is being expanded, contact the system admins if you are unsure
if a piece of software you want to use is already installed.

.. Note::
	Some codes require the user to present the necissary license information to the system admins before access is granted to the software package.  Examples include MCNP, NJOY, VERA, and SCALE.
