#!/bin/bash
#set -e
source conf/conf.sh
source ../common.sh
echo "start run-client.sh"

label=$1

if [[ $# -lt 1 ]]; then
  echo "needs two parameter: ./stat-client.sh [log directory] [label name]"
  exit
fi

cwd=`pwd`
out_avg="${cwd}/data/avg-client.ts"
stat_client="${cwd}/data/stat-client.ts"

echo "label = $label"
$plotter/gen-stat.pl $out_avg $stat_client $label
# generate eps plot using the data points
gnuplot < $plotter/stat-client.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
#mogrify -format png *.eps
convert -density 150  stat-client.pdf stat-client.png

fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
echo "end run-client.sh"
