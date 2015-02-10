#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
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

