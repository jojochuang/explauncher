#!/bin/bash
#set -e

source conf/conf.sh
source ../common.sh
cwd=`pwd`

if [[ $# -ge 2 ]]; then
  type=$1
  logdir=$2
fi

cd $logdir
echo "parse-throughput.sh: at $logdir"
# Which file do you want to plot?

# find the latest log set in the dir
#headfile=(`find . -name 'head*[^sar]\.log\.gz' | tail -1`)
headfile=(`find $dir -name "head-*" -not -name "*sar*"`)
echo "headfile = $headfile"
#svfile=(`find . -name 'server*[^sar]\.log\.gz'`)
svfile=(`find $dir -name "server-*" -not -name "*sar*"`)
echo "svfile = $svfile"

start_time=0
#rm ${cwd}/data/server-*.ts
#rm ${cwd}/data/head-throughput.ts
fs=`find ${cwd}/data -name 'server-*.ts'`
if [ -z "$fs" ]; then
  echo "no server-*.ts found in ${cwd}/data/"
else
  rm $fs
fi
#for f in "${cwd}/data/server-*.ts"; do
#  rm $f
#done
#for f in ${cwd}/data/head-throughput.ts; do
fs=`find ${cwd}/data -name 'head-*.ts'`
if [ -z "$fs" ]; then
  echo "no head-*.ts found in ${cwd}/data/"
else
  rm $fs
fi
start_time=0
echo "headfile = $headfile"
# For headfile, generate plot file
for f in "${headfile[@]}"; do
  echo "head = $f"

  start_time_us=`zgrep -a -e "HeadEventTP::constructor" $f | head -1 | awk '{print int($1)}' | tr -d '\r\n'`
  head_start_time=$start_time_us

  if [ -z "$head_start_time" ]; then
    echo "start time not found in the log"
    exit 1
  else
    echo "start at $head_start_time"
  fi
  
  if [ $start_time -eq 0 ]; then
      start_time=$head_start_time
  elif [ $start_time -gt $head_start_time ]; then
      start_time=$head_start_time
  fi
done
# For headfile, generate plot file
for f in "${headfile[@]}"; do
  echo "head = $f"

  #start_time_us=`zgrep -a -e "HeadEventTP::constructor" $f | head -1 | awk #'{print $1}' | tr -d '\r\n'`
  #echo "start time=$start_time_us"
  #start_time=$start_time_us

  #if [ -z "$start_time" ]; then
  #  echo "start time not found in the log"
  #  exit 1
  #else
    # throughput
    #out="${cwd}/data/head-throughput.ts"
    out="${cwd}/data/"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
    echo "producing $out"
    zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  #fi
done

echo "start= " $start_time
# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"

  # throughput
  out="${cwd}/data/"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  echo "producing $out"
  zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  #cat $out
done

# combine the throughput of each physical node into a single time series
input_ts=(`find ${cwd}/data -name "head*.ts" -o -name "server*.ts"`)
echo "input_ts="  ${input_ts[@]};
out_avg="${cwd}/data/avg-throughput.ts"
echo "out_avg "  $out_avg;
$plotter/aggregator.pl  $out_avg ${input_ts[@]}  $logdir

