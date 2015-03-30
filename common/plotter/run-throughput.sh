#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
echo "start run-throughput.sh"

logset=$1

label=$2

if [[ $# -lt 2 ]]; then
  echo "needs two parameter: ./run-throughput.sh [log directory] [label name]"
  exit
fi

cwd=`pwd`
out_avg="${cwd}/data/avg-throughput.ts"
stat_throughput="${cwd}/data/stat_throughput.ts"

echo "label = $label"
$plotter/gen-stat.pl $out_avg $stat_throughput $label
# generate eps plot using the data points
gnuplot < $plotter/stat-throughput.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
#mogrify -format png *.eps
convert -density 150  stat-throughput.pdf stat-throughput.png

fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
echo "end run-throughput.sh"
