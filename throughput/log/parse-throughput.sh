#!/bin/bash

application="throughput"
source ../../common.sh
cwd=`pwd`

if [[ $# -ge 2 ]]; then
  type=$1
  logdir=$2
fi

cd $logdir
echo "parse-throughput.sh: at $logdir"
# Which file do you want to plot?

# find the latest log dir
#dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
#echo "dir = $dir"
# find the latest log set in the dir
headfile=(`find . -name 'head-*.gz' | tail -1`)
echo "headfile = $headfile"
svfile=(`find . -name 'server-*.gz'`)
echo "svfile = $svfile"

start_time=0
rm ${cwd}/data/server-*.ts
rm ${cwd}/data/head-throughput.ts
# For headfile, generate plot file
for f in "${headfile[@]}"; do
  echo "head = $f"

  start_time_us=`zgrep -a -e "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  echo "start time=$start_time_us"
  start_time=$(($start_time_us / 1000000))

  # throughput
  out="${cwd}/data/head-throughput.ts"
  #if [ -f $out ]; then
  #  rm $out
  #fi
  echo "producing $out"
  zgrep -a -e "EVENT_FINISH" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
done

echo "start= " $start_time
# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"

  # throughput
  out="${cwd}/data/"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  echo "producing $out"
  zgrep -a -e "EVENT_FINISH" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out
  #cat $out
done

# combine the throughput of each physical node into a single time series
input_ts=(`find ${cwd}/data -regex '.*\(server\|head\).*ts'`)
echo "input_ts="  ${input_ts[@]};
out_avg="${cwd}/data/avg-throughput.ts"
echo "out_avg "  $out_avg;
${cwd}/aggregator.pl  $out_avg ${input_ts[@]}  $logdir

exit;
# TODO: use the new 

# copy the template
#cp ${cwd}/avg-throughput.plot ${cwd}/avg-throughput-combined.plot

# append to the template
#n=2
#input_size=${#input_ts[@]}
#linewidth=3
#for f in "${input_ts[@]}"; do
#  sep=", \\"
#  if [ $(($n-2+1)) -eq $input_size ]; then
#    sep=""
#  fi
#  color=$(($n-2))
#  nopath=`echo $f|sed 's/^.*\///'` #remove the  path name
#  echo "'$out_column'    using 1:(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${cwd}/avg-throughput-combined.plot
#  n=$(($n+1))
#done

# Process the file
#newout="${cwd}/data/client-latency.ts"
#echo "producing $newout"
#cat $out | sort -k +1n | ${cwd}/sma.awk P=50 > $newout
