#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh

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
#if [ -f $out_avg ]; then
#  rm $out_avg
#fi

for log in $logset/*
do
  #echo "generating instant"
  # check for assertion failures in the latest logs
  $plotter/check-assert.sh $type $log
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure in the log."
  fi
  # generate data points from the log
  $plotter/parse-throughput.sh $type $log
done
  # compute average of average, and std dev of the average.
  # output data
echo "label = $label"
$plotter/gen-stat.pl $out_avg $stat_throughput $label
# generate eps plot using the data points
gnuplot < $plotter/stat-throughput.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps

fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
