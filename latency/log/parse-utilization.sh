#!/bin/bash
#set -e
source ../conf/conf.sh
source ../../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd

if [[ $# -ge 1 ]]; then
  logdir=$1
fi

cd $logdir

# Which file do you want to plot?
# find the latest log dir
dir="."
# find the latest log set in the dir
# TODO: only server and head
sarfile=(`find $dir -name '*.sar'`)

# get the latency of both get and put requests at the client side

#get_out="${cwd}/data/get-latency.ts" #remove the file name suffix
#if [ -f $get_out ]; then
#  rm $get_out
#fi
#put_out="${cwd}/data/put-latency.ts" #remove the file name suffix
#if [ -f $put_out ]; then
#  rm $put_out
#fi

rm *.tmp

for f in "${sarfile[@]}"; do
  echo "sar file = $f"
  g=$(basename "$f")
  i="${g%%.*}"
  
  sadf -- -u $sarfile | grep %idle | awk '{print $8}' >> data/cpu.tmp
done

# compute average cpu utilization:
awk 'BEGIN{sum=0} {sum+=$1} END{print (100.0 - sum/NR) }' data/cpu.tmp >> data/utilization.ts

