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

# Which file do you want to plot?
if [[ "$type" = "instant" ]]; then
  # find the latest log dir
  dir="."
  echo "dir=$dir"
  # find the latest log set in the dir
  headfile=(`find $dir -name 'head-*-[0-9]*.gz' | tail -1`)
  clifile=(`find $dir -name '*player*.gz'`)
  svfile=(`find $dir -name 'server-*.gz'`)
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
    out="${cwd}/data/net-write-head.ts"
    if [ -f $out ]; then
      rm $out
    fi
    echo "producing $out"
    zgrep -a -e "Accumulator::NETWORK_WRITE" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

    out="${cwd}/data/net-read-head.ts"
    if [ -f $out ]; then
      rm $out
    fi
    echo "producing $out"
    zgrep -a -e "Accumulator::NETWORK_READ" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  fi

done

# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"
  
  out="${cwd}/data/net-write-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  if [ -f $out ]; then
    rm $out
  fi
  echo "producing $out"
  zgrep -a -e "Accumulator::NETWORK_WRITE" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

  out="${cwd}/data/net-read-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  if [ -f $out ]; then
    rm $out
  fi
  echo "producing $out"

  zgrep -a -e "Accumulator::NETWORK_READ" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

done
echo "start time at $start_time"
input_ts=(`find ${cwd}/data -regex '.*net-write-\(server\|head\).*ts'`)
echo "input_ts="  ${input_ts[@]};
out_column="${cwd}/data/column-net-write.ts"
echo "out_column "  $out_column;
${plotter}/columnizer.pl $out_column ${input_ts[@]} 

cp ${plotter}/net-write-timeseries.plot ${plotter}/net-write-timeseries-combined.plot
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
  echo "'$out_column'    using 1:(\$${n}/1024) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/net-write-timeseries-combined.plot
  n=$(($n+1))
done

input_ts=(`find ${cwd}/data -regex '.*net-read-\(server\|head\).*ts'`)
echo "input_ts="  ${input_ts[@]};
out_column="${cwd}/data/column-net-read.ts"
echo "out_column "  $out_column;
${plotter}/columnizer.pl $out_column ${input_ts[@]} 

cp ${plotter}/net-read-timeseries.plot ${plotter}/net-read-timeseries-combined.plot
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
  echo "'$out_column'    using 1:(\$${n}/1024) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/net-read-timeseries-combined.plot
  n=$(($n+1))
done


