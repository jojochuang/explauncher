#!/bin/bash

application="throughput"
source ../../common.sh

logset=$1

label=$2

if [[ $# -lt 2 ]]; then
  echo "needs two parameter: ./run-throughput.sh [log directory] [label name]"
  exit
fi

type="instant"
cwd=`pwd`
out_avg="${cwd}/data/avg-throughput.ts"
stat_throughput="${cwd}/data/stat_throughput.ts"
if [ -f $out_avg ]; then
  rm $out_avg
fi
#if [ -f $stat_throughput ]; then
#  rm $stat_throughput
#fi

for log in $logset/*
do
  #echo "generating instant"
  # check for assertion failures in the latest logs
  ./check-assert.sh $type $log
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure in the log."
    #exit 0
  fi
  # generate data points from the log
  ./parse-throughput.sh $type $log
done
  # compute average of average, and std dev of the average.
  # output data
#label=`date --iso-8601="seconds"`
echo "label = $label"
#awk $out_avg 'BEGIN{avg=0;run=0;stddev=0.0}{avg+=$6;run++}END{avg /=run;}'
gen-stat.pl $out_avg $stat_throughput $label
# generate eps plot using the data points
gnuplot < stat-throughput.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps
rm *.eps

