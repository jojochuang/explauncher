#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd

if [[ $# -lt 1 ]]; then
  logset=`ls -trd ${logdir}/${application}-* | tail -n1`
else
  logset=$1
fi 

cd $logset

# Which file do you want to plot?
# find the latest log set in the dir
# TODO: only server and head
sarfile=(`find . -name '[head|server]*sar.log.gz'`)
#echo $sarfile

# get the latency of both get and put requests at the client side

#get_out="${cwd}/data/get-latency.ts" #remove the file name suffix
#if [ -f $get_out ]; then
#  rm $get_out
#fi
#put_out="${cwd}/data/put-latency.ts" #remove the file name suffix
#if [ -f $put_out ]; then
#  rm $put_out
#fi

rm ${cwd}/data/*.tmp

touch ${cwd}/data/cpu.tmp

#echo "${sarfile[@]}"
for f in "${sarfile[@]}"; do
  echo "sar file = $f"
  #g=$(basename "$f")
  #i="${g%%.*}"
  b=`basename $f .gz`
  
  pwd
  echo $b
  gunzip "${b}.gz"
  sadf -- -u $b | grep %idle | awk '{print $8}' >> ${cwd}/data/cpu.tmp
done

touch ${cwd}/data/utilization.ts
# compute average cpu utilization:
ln=`wc -l ${cwd}/data/utilization.ts |cut -d" " -f1`
ln=$(( $ln+1 ))
awk -v vln="$ln" 'BEGIN{sum=0} {sum+=(100-$1);array[NR]=(100-$1)} END{for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);};print vln " " sum/NR " " sqrt(sumsq/NR) }' ${cwd}/data/cpu.tmp >> ${cwd}/data/utilization.ts

