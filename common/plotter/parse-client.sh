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
# find the latest log dir
dir="."
echo "dir=$dir"
# find the latest log set in the dir
clientfile=(`find $dir -name "client-*" -not -name "*sar*"`)

start_time=0
echo "clientfile = $clientfile"
# For clientfile, generate plot file
for f in "${clientfile[@]}"; do
  echo "client log = $f"

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
for f in "${clientfile[@]}"; do
  echo "head = $f"

    # throughput
    out="${cwd}/data/throughput-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
    if [ -f $out ]; then
      rm $out
    fi
    echo "producing $out"
    zgrep -a -e "\[ZKClient[SG]et\]" $f | awk "{ T=int(\$1 - $start_time); counter[T]++;}END{ for( c in counter){printf(\"%d\t%d\n\",c,counter[c]);} }" | sort -k +1n > $out
  #fi

done
echo "start time at $start_time"
#input_ts=(`find ${cwd}/data -name "throughput-head-*.ts" -o -name "throughput-server-*.ts"`)
input_ts=(`find ${cwd}/data -name "throughput-client-*.ts"`)
echo "input_ts="  ${input_ts[@]};
out_column="${cwd}/data/column-client.ts"
echo "out_column "  $out_column;
$plotter/columnizer.pl $out_column ${input_ts[@]} 

cp $plotter/timeseries-client.plot $plotter/timeseries-client-combined.plot
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
  echo "'$out_column'    using 1:(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/timeseries-client-combined.plot
  n=$(($n+1))
done

input_ts=(`find ${cwd}/data -name "throughput-client*.ts"`)
echo "input_ts="  ${input_ts[@]};
out_avg="${cwd}/data/avg-client.ts"
echo "out_avg "  $out_avg;
$plotter/aggregator.pl  $out_avg ${input_ts[@]}  $logdir

