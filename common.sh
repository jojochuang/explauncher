#!/bin/bash

ec2=0        # set this if you are experimenting on EC2

if [[ $ec2 -eq 0 ]]; then
  user="chuangw"
  home="/homes/chuangw"                                       # Home directory
  bin="/homes/chuangw/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir="/u/tiberius06_s/chuangw/logs/${application}"        # Log collection directory
  scratchdir="/scratch/chuangw/tmp/${application}"            # Scratch directory location
  psshdir="/homes/chuangw/pssh/bin"
else
  user="ubuntu"
  home="/home/ubuntu"                                       # Home directory
  bin="/home/ubuntu/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir="/home/ubuntu/logs/${application}"        # Log collection directory
  scratchdir="/run/shm/tmp/${application}"            # Scratch directory location
  psshdir="/home/ubuntu/pssh-2.2/bin"
fi
