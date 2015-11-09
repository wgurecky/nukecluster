The Nukestar Cluster Package
============================

Documentation avalible at:
<https://wgurecky.github.io/nukecluster>

This package contains an introductory setup and
maintenance guide for the Nukestar Computing Cluster at The University of Texas
at Austin.  Setup and maintenance scripts are also provided.

The configuration and automation scripts are written in a combination of
bash and Ansible playbook (yaml) formats.  Ansible eases cluster management by 
organizing tasks based on the target machine type.  Typical administrative
tasks for the storage nodes is much different than administrative tasks for 
the head and compute nodes, for example.  Furthermore, Ansible makes use 
of the existing ssh infrastructure and does not require any client software
to be set up on the target machines.

Contacts
=========

William Gurecky
---
william.gurecky@utexas.edu

