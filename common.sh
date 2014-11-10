#!/bin/bash

# Configures parameters that are shared by all benchmarks

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
conf_dir="${bin}/conf"                    # Configuration directory
conf_orig_file="conf/params-basic.conf"   # Relative directory of conf_orig_file
host_orig_file="conf/hosts"
host_run_file="conf/hosts-run"
boot_file="conf/boot"

function GenerateCommonParameter () {
  conf_file=$1
  echo "USER = ${user}" >> ${conf_file}
  echo "HOME = ${home}" >> ${conf_file}
  echo "BIN = ${bin}" >> ${conf_file}
  echo "CONFDIR = ${conf_dir}" >> ${conf_file}
  echo "HOSTRUNFILE = ${conf_dir}/hosts-run" >> $conf_file
  #echo "HOSTNOHEADFILE = ${conf_dir}/hosts-run-nohead" >> $conf_file
  echo "BOOTFILE = ${conf_dir}/boot" >> $conf_file
  echo "CONFFILE = ${conf_dir}/params-run.conf" >> $conf_file
  echo "LOGDIR = ${logdir}" >> $conf_file
  echo "SCRATCHDIR = ${scratchdir}" >> $conf_file
  echo "PSSHDIR = ${psshdir}" >> $conf_file
}
