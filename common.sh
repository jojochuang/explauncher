#!/bin/bash

# Configures parameters that are shared by all benchmarks

ec2=1        # set this if you are experimenting on EC2

if [[ $ec2 -eq 0 ]]; then
  user="chuangw"
  home="/homes/chuangw"                                       # Home directory
  benchmark_root="/homes/chuangw/benchmark"
  bin="/homes/chuangw/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir_base="/u/tiberius06_s/chuangw/logs"        # Log collection directory
  logdir="/u/tiberius06_s/chuangw/logs/${application}"        # Log collection directory
  scratchdir="/scratch/chuangw/tmp/${application}"            # Scratch directory location
  psshdir="/homes/chuangw/pssh/bin"
  webdir_base="/homes/chuangw/.www/benchmark"
  webdir="/homes/chuangw/.www/benchmark/$application"
  url_prefix="/homes/chuangw/benchmark/$application/"
else
  user="ubuntu"
  home="/home/ubuntu"                                       # Home directory
  benchmark_root="/home/ubuntu/benchmark"
  bin="/home/ubuntu/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir_base="/home/ubuntu/logs"        # Log collection directory
  logdir="/home/ubuntu/logs/${application}"        # Log collection directory
  scratchdir="/run/shm/tmp/${application}"            # Scratch directory location
  psshdir="/home/ubuntu/pssh-2.2/bin"
  webdir_base="/var/www/benchmark"
  webdir="/var/www/benchmark/$application"
  url_prefix="/benchmark/$application/"
fi
common="$benchmark_root/common"               # Default explauncher experiment directory. Also, binary executable exists at this directory.
plotter="$benchmark_root/common/plotter"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

conf_dir="${bin}/conf"                    # Configuration directory
conf_orig_file="conf/params-basic.conf"   # Relative directory of conf_orig_file
host_orig_file="../ec2/conf/hosts"
host_run_file="conf/hosts-run"
boot_file="conf/boot"

flavor="nacho"
#flavor="context"
config_only=0 # don't run the experiment. just generate config files.


function GenerateCommonParameter () {
  conf_file=$1
  echo "USER = ${user}" >> ${conf_file}
  echo "HOME = ${home}" >> ${conf_file}
  echo "COMMON = ${common}" >> ${conf_file}
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
