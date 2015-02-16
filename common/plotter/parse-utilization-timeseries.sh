#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
cwd=`pwd`

if [[ $# -ge 1 ]]; then
  logdir=$1
fi

conf_file="conf/params-run-server.conf"
worker_join_wait_time=`grep $conf_file -e "WORKER_JOIN_WAIT_TIME"| awk '{print $3}'`
client_wait_time=`grep $conf_file -e "CLIENT_WAIT_TIME"| awk '{print $3}'`
total_boot_time=`grep $conf_file -e "TOTAL_BOOT_TIME"| awk '{print $3}'`
# sleep_time is the time when all clients are sending data.
sleep_time=$(( $worker_join_wait_time + $client_wait_time + $total_boot_time ))

cd $logdir

# Which file do you want to plot?
# find the latest log dir
dir="."
echo "dir=$dir"
# find the latest log set in the dir
svfile=(`find . -name 'head*.log.gz' -a -name "*sar*.log.gz" -o -name 'server*.log.gz' -a -name "*sar*.log.gz"`)

# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"
  
  out="${cwd}/data/utilization-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  if [ -f $out ]; then
    rm $out
  fi
  echo "producing $out"

  b=`basename $f .gz`
  pwd
  gunzip "${b}.gz"
  sadf -- -u $b | grep %idle | awk '{print NR "\t" (100-$8) }' > $out
  gzip ${b}
done

echo "start time at $start_time"
input_ts=(`find ${cwd}/data -name 'utilization-*.ts'`)
echo "input_ts="  ${input_ts[@]};
out_column="${cwd}/data/column-utilization.ts"
echo "out_column "  $out_column;
${plotter}/columnizer.pl $out_column ${input_ts[@]} 

cp ${plotter}/utilization-timeseries.plot ${plotter}/utilization-timeseries-combined.plot
n=2
input_size=${#input_ts[@]}
linewidth=3
for f in "${input_ts[@]}"; do
  sep=", \\"
  if [ $(($n-2+1)) -eq $input_size ]; then
    sep=""
  fi
  color=$(($n-2))
  nopath=`echo $f|sed 's/^.*\///'` #remove the  path name
  echo "'$out_column'    using 1:(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/utilization-timeseries-combined.plot
  n=$(($n+1))
done
