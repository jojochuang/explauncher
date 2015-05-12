**esting Tools**

Introduction
=======

Automating experiment is critical to collect all the necessary numbers.

This is the tools written in bash and python script that simplifies
and automates running an experiment.


Prerequisite
=======

1. Install pssh (preferrably 2.2) and add the path to the pssh executable in your PATH. Pssh can be downloaded at [here] (https://code.google.com/p/parallel-ssh/)

2. Clone this repo to /YOUR/TOOLDIR. e.g. `cd ~/; git clone https://github.com/jojochuang/explauncher benchmark`

3. Create symbolic link of the executable file under your /YOUR/TOOLDIR/PROJECTNAME/.
   For example, if your project name is "microbenchmark" and flavor is "context",
   you should name the symlink to be "microbenchmark\_context".

4. Copy and create your params-basic.conf from
   params-basic.conf-example.
   Also, copy and create your hosts file from hosts-example.
   Change default user and directory settings in .conf file and run.sh file.


Design
=======

  * `run.sh`

    This would be the top-level experiment execution file.
    It usually launch series of multiple experiments sequentially.

    Modify the shell script file for your own needs.

  * `configure.py`

    Read from hosts and basic parameter files to create boot and hosts-run files.

  * `master-run.py`

    Script that runs at the master node. (Usually where you launch the application)

  * `worker-run.py`

    Script that will spawn at the each of the machines.

  * `worker-log.py`

    It collect the all the log to your log directory.

  * `log/run-TYPE_OF_DATA.sh`
  
    Usually this would be the file that you will run to analyze the log.

  * `conf/params-basic.conf`

    Your default configuration file for your application. This setting will be copy-and-pasted
    to the actual running system.

  * `conf/params-run.conf`

    This file will be generated automatically by configure-PROJECTNAME.py. 
    Usually it has added configuration key-value pairs like mapping and nodeset.

  * `conf/hosts`

    List your actual machines to use for your experiment. e.g. tiberius01 tibrius02

  * `conf/hosts-run`

    This file will be generated automatically by configure-PROJECTNAME.py with your given
    actual number of node you will be using.

  * `conf/hosts-run-nohead`

    This file will be generated automatically by configure-PROJECTNAME.py with your given
    actual number of node you will be using.

  * `conf/boot`

    This file will be generated automatically by configure-PROJECTNAME.py with your given
    actual number of node you will be using.

Contacts
======

Feel free to ask any questions to use this scripts.

* [Wei-Chiu Chuang](http://weichiu.com/about-wei-chiu/) email: <weichiu@purdue.edu>
* This project is extended from Sunghwan's [explauncher] (https://bitbucket.org/shyoo/explauncher)



