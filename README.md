**esting Tools**

Introduction
=======

Automating experiment is critical to collect all the necessary numbers.

This is the tools written in bash and python script that simplifies
and automates running an experiment.


Prerequisite
=======

1. Install pssh (preferrably 2.2) and add the path to the pssh executable in your PATH.

2. Create symbolic link of the executable file to your /YOUR/TOOLDIR/PROJECTNAME\_FLAVOR.
   For example, if your project name is "microbenchmark" and flavor is "context",
   you should name the symlink to be "microbenchmark\_context".

3. Change default user and directory settings in various .py files to meet your need.


Design
=======

  * run-PROJECTNAME.sh

    This would be the top-level experiment execution file.
    It usually launch series of multiple experiments sequentially.

    Modify the shell script file for your own needs.

  * configure-PROJECTNAME.py

    Read from hosts and basic parameter files to create boot and hosts-run files.

  * master-run-PROJECTNAME.py

    Script that runs at the master node. (Usually where you launch the application)

  * worker-run-PROJECTNAME.py

    Script that will spawn at the each of the machines.

  * worker-log-PROJECTNAME.py

    It collect the all the log to your log directory.

  * log/PROJECTNAME/

    Log analyzer will be listed in here.

    * compile-PROJECTNAME.sh
    
      Usually this would be the file that you will run to analyze the log.

  * conf/PROJECTNAME/

    Your all configuration file should be located here.

    * params-basic-PROJECTNAME.conf

      Your default configuration file for your application. This setting will be copy-and-pasted
      to the actual running system.

    * params-run-PROJECTNAME.conf

      This file will be generated automatically by configure-PROJECTNAME.py. 
      Usually it has added configuration key-value pairs like mapping and nodeset.

    * hosts

      List your actual machines to use for your experiment. e.g. tiberius01 tibrius02

    * hosts-run

      This file will be generated automatically by configure-PROJECTNAME.py with your given
      actual number of node you will be using.

    * hosts-run-nohead

      This file will be generated automatically by configure-PROJECTNAME.py with your given
      actual number of node you will be using.

    * boot

      This file will be generated automatically by configure-PROJECTNAME.py with your given
      actual number of node you will be using.

Contacts
======

Feel free to ask any questions to use this scripts.

* [Sunghwan Yoo](http://www.cs.purdue.edu/homes/yoo7/) email: <sunghwanyoo@purdue.edu>



