#!/bin/bash
#set -e
source ../conf/conf.sh
source ../../common.sh
#logdir=/u/tiberius06_s/chuangw/logs/ranger
cwd=`pwd`
#echo $cwd

if [[ $# -ge 1 ]]; then
  logdir=$1
fi

cd $logdir

# Which file do you want to plot?
# find the latest log dir
dir="."
# find the latest log set in the dir
#headfile=(`find $dir -name 'head-*.gz' | tail -1`)
clifile=(`find $dir -name 'client-*.gz'`)
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

for f in "${clifile[@]}"; do
  echo "client file = $f"
  
  zgrep -a -e "GET" $f |  awk '{if($3 == "[BS_KeyValueClient]" ){print $8} }'  >> $get_out
  zgrep -a -e "PUT" $f |  awk '{if($3 == "[BS_KeyValueClient]" ){print $8} }'  >> $put_out
done

avglat="${cwd}/data/avg-latency.ts"
ln=0
if [ -f $avglat ];  then
  ln=`wc $avglat | awk '{print $1}' `
fi
ln=$(($ln/2))
ln=$(($ln+1))
awk -v vln="$ln" '{sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print vln "-GET " sum/NR " " sqrt(sumsq/NR)}' $get_out >> $avglat 
awk -v vln="$ln" '{sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print vln "-PUT " sum/NR " " sqrt(sumsq/NR)}' $put_out >> $avglat

#input_ts=(`find ${cwd}/data -regex '.*.*ts'`)
#echo "input_ts="  ${input_ts[@]};
#out_column="${cwd}/data/column-throughput.ts"
#echo "out_column "  $out_column;
#${cwd}/columnizer.pl $out_column ${input_ts[@]} 
#
#cp ${cwd}/timeseries-throughput.plot ${cwd}/timeseries-throughput-combined.plot
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
#  echo "'$out_column'    using 1:(\$${n}) title \"$nopath\"   lt $color pt 0 lw $linewidth axes x1y1 $sep" >> ${cwd}/timeseries-throughput-combined.plot
#  n=$(($n+1))
#done

