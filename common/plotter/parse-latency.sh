#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd


function aggregate_time_series () {
    input_ts=(`find ${cwd}/data -name 'latency-client*.ts'`)
    echo "input_ts="  ${input_ts[@]};
    out_column="${cwd}/data/column-latency.ts"
    out_combined="${cwd}/data/combined-latency.ts"
    echo "out_column "  $out_column;
    ${plotter}/columnizer.pl $out_column ${input_ts[@]} 
    ${plotter}/combiner.pl $out_combined $out_column 

    cp ${plotter}/latency-timeseries.plot ${plotter}/latency-timeseries-combined.plot
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
      echo "'$out_column'    using (\$1-start_time):(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${plotter}/latency-timeseries-combined.plot
      n=$(($n+1))
    done
}

if [[ $# -ge 1 ]]; then
  logdir=$1
fi

cd $logdir

# Which file do you want to plot?
# find the latest log dir
dir="."
# find the latest log set in the dir
#headfile=(`find $dir -name 'head-*.gz' | tail -1`)
clifile=(`find $dir -name 'client*[^sar]\.log\.gz'`)
#svfile=(`find $dir -name 'server-*.gz'`)

# get the latency of both get and put requests at the client side

get_out="${cwd}/data/get-latency.ts" #remove the file name suffix
if [ -f $get_out ]; then
  rm $get_out
fi
put_out="${cwd}/data/put-latency.ts" #remove the file name suffix
if [ -f $put_out ]; then
  rm $put_out
fi

rm ${cwd}/data/latency-client*.ts

for f in "${clifile[@]}"; do
  echo "client file = $f"
  out="${cwd}/data/latency-"`echo $f|sed 's/^.*\///'| sed 's/\.log\.gz//'`".ts" #remove the file name suffix
  if [ -f "$out" ]; then
      rm -f $out
  fi
  touch $out
  
  zgrep -a -e "GET" $f |  awk 'BEGIN{start_time=0}{if($3 == "[BS_KeyValueClient]" ){lat[ int($1) ] += $8; count[ int($1) ]++;}if(start_time==0){start_time=int($1)} } END{for(x in lat){print (x) "\t" (lat[x]/count[x]) } }' | sort -n  > $out
  zgrep -a -e "GET" $f |  awk '{if($3 == "[BS_KeyValueClient]" ){print $8} }'  >> $get_out

  zgrep -a -e "PUT" $f |  awk '{if($3 == "[BS_KeyValueClient]" ){print $8} }'  >> $put_out
done

# aggregate time series
aggregate_time_series

# aggregate all latency data in multiple runs
allraw="${cwd}/data/all_raw_latency.ts"
touch $allraw
cat $get_out >> $allraw
cat $put_out >> $allraw

avglat="${cwd}/data/avg-latency.ts"
ln=0
if [ -f $avglat ];  then
  ln=`wc $avglat | awk '{print $1}' `
fi
ln=$(($ln/2))
ln=$(($ln+1))

sort -n $get_out -o $get_out
sort -n $put_out -o $put_out
# number of lines in 
num_lines=`wc -l $get_out | cut -d" " -f1`
# get the median number
median_element=$(( $num_lines/2 ))
# get average

# get 90th percentile
ninetyth=$(( $num_lines*9/10 ))

awk -v vln="$ln" -v me="$median_element" -v ne="$ninetyth" '{sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print vln "-GET " sum/NR " " sqrt(sumsq/NR) " " array[me] " " array[ne] }' $get_out >> $avglat 
awk -v vln="$ln" -v me="$median_element" -v ne="$ninetyth" '{sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print vln "-PUT " sum/NR " " sqrt(sumsq/NR) " " array[me] " " array[ne] }' $put_out >> $avglat

