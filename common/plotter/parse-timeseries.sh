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
if [[ "$type" = "instant" ]]; then
  # find the latest log dir
  dir="."
  echo "dir=$dir"
  # find the latest log set in the dir
  headfile=(`find $dir -name 'head-*-[0-9]*.gz' | tail -1`)
  clifile=(`find $dir -name '*player*.gz'`)
  svfile=(`find $dir -name 'server-*[0-9]*.gz'`)
else
  dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
  headfile=(`find $dir -name 'head*-[0-9]*.gz' | tail -1`)
  clifile=(`find $dir -name '*player*.gz'`)
  nsfile=(`find $dir -name '*.nserver.conf' | tail -1`)
  cutoff=220000000
fi

start_time=0
echo "headfile = $headfile"
# For headfile, generate plot file
for f in "${headfile[@]}"; do
  echo "head = $f"

  start_time_us=`zgrep -a -e "HeadEventTP::constructor" $f | head -1 | awk '{print $1}' | tr -d '\r\n'`
  start_time=$start_time_us

  if [ -z "$start_time" ]; then
    echo "start time not found in the log"
    exit 1
  else
  echo "start time at $start_time"

    # throughput
    out="${cwd}/data/head-throughput.ts"
    if [ -f $out ]; then
      rm $out
    fi
    echo "producing $out"
    zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  fi

done

# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"
  
  out="${cwd}/data/"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  rm $out
  echo "producing $out"
  zgrep -a -e "Accumulator::EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

done
  echo "start time at $start_time"
input_ts=(`find ${cwd}/data -regex '.*\(server\|head\).*ts'`)
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


if [[ "$type" = "publish" ]]; then
  # For nserver file
  for f in "${nsfile[@]}"; do
    echo "nserver = $f"
    out="${cwd}/data/head-nservers.ts"
    echo "producing $out"
    zgrep -a -e " num_servers" $f | awk "{ T=int(\$3); printf \"%.3f\t%d\n\", (T/1000000), \$4}" > $out
  done
fi

