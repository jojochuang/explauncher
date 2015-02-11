#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd

conf_file="conf/params-run-server.conf"
worker_join_wait_time=`grep $conf_file -e "WORKER_JOIN_WAIT_TIME"| awk '{print $3}'`
client_wait_time=`grep $conf_file -e "CLIENT_WAIT_TIME"| awk '{print $3}'`
sleep_time=$(( $worker_join_wait_time + $client_wait_time ))
if [[ $# -lt 2 ]]; then
  logset=`ls -trd ${logdir}/${application}-* | tail -n1`
else
  logset=$1
fi 

#echo $sleep_time


cd $logset

# Which file do you want to plot?
# find the latest log set in the dir
# TODO: only server and head
sarfile=(`find . -name '[head|server]*sar.log.gz'`)
cwd2=`pwd`
echo "cwd2=$cwd2"
#echo $sarfile

# get the latency of both get and put requests at the client side

rm ${cwd}/data/*.tmp

touch ${cwd}/data/cpu.tmp

#echo "sarfile=$sarfile"
#echo "${sarfile[@]}"
for f in "${sarfile[@]}"; do
  echo "sar file = $f"
  #g=$(basename "$f")
  #i="${g%%.*}"
  b=`basename $f .gz`
  
  pwd
  #echo $b
  gunzip "${b}.gz"
  sadf -- -u $b | grep %idle | awk '{print $8}' >> ${cwd}/data/cpu_uncropped.tmp
  data_len=`wc ${cwd}/data/cpu.tmp | awk '{print $1}'`
  tail_len=$(( $data_len - $sleep_time ))
  #echo "tail_len = $tail_len, data_len=$data_len, sleep_time=$sleep_time"
  tail -n $tail_len ${cwd}/data/cpu_uncropped.tmp > ${cwd}/data/cpu.tmp
  wc ${cwd}/data/cpu.tmp
  #echo "done $f"
done

cat ${cwd}/data/cpu.tmp

touch ${cwd}/data/utilization.ts
# compute average cpu utilization:
ln=`wc -l ${cwd}/data/utilization.ts |cut -d" " -f1`
ln=$(( $ln+1 ))
awk -v vln="$ln" 'BEGIN{sum=0} {sum+=(100-$1);array[NR]=(100-$1)} END{for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);};print vln " " sum/NR " " sqrt(sumsq/NR) }' ${cwd}/data/cpu.tmp >> ${cwd}/data/utilization.ts

