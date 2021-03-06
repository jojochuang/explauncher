#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd

if [[ $# -ge 2 ]]; then
  type=$1
  logdir=$2
fi

cd $logdir

# Which file do you want to plot?
# find the latest log dir
dir="."
echo "dir=$dir"
# find the latest log set in the dir
headfile=(`find $dir -name "head-*" -not -name "*sar*"`)

svfile=(`find $dir -name "server-*" -not -name "*sar*"`)

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
for f in "${headfile[@]}"; do
  echo "head = $f"

    # throughput
    out="${cwd}/data/throughput-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
    if [ -f $out ]; then
      rm $out
    fi
    echo "producing $out"
    zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  #fi

done

# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"
  
  out="${cwd}/data/throughput-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  rm $out
  echo "producing $out"
  zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

done
echo "start time at $start_time"
#input_ts=(`find ${cwd}/data -regex '.*\(server\|head\).*ts'`)
input_ts=(`find ${cwd}/data -name "throughput-head-*.ts" -o -name "throughput-server-*.ts"`)
echo "input_ts="  ${input_ts[@]};
out_column="${cwd}/data/column-throughput.ts"
echo "out_column "  $out_column;
$plotter/columnizer.pl $out_column ${input_ts[@]} 

cp $plotter/timeseries-throughput.plot $plotter/timeseries-throughput-combined.plot
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
  echo "'$out_column'    using 1:(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/timeseries-throughput-combined.plot
  n=$(($n+1))
done

input_ts=(`find ${cwd}/data -name "throughput-head*.ts" -o -name "throughput-server*.ts"`)
echo "input_ts="  ${input_ts[@]};
out_avg="${cwd}/data/avg-throughput.ts"
echo "out_avg "  $out_avg;
$plotter/aggregator.pl  $out_avg ${input_ts[@]}  $logdir

