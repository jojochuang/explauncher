#!/bin/bash
#set -e

source conf/conf.sh
source ../common.sh

if [[ $# -lt 1 ]]; then
  logset=`ls -trd ${logdir}/${application}-* | tail -n1`
else
  logset=$1
fi 

echo "logdir=$logdir"
echo "logset=$logset"

# generate data points from the log
$plotter/parse-utilization-timeseries.sh $logset
# generate eps plot using the data points
gnuplot < $plotter/utilization-timeseries-combined.plot

fs=`find data/ -name 'utilization-*.ts'`
if [ -z "$fs" ]; then
  echo "no utilization-*.ts found in data/"
else
  rm $fs
fi

# generate pdf files using the eps file.
cd result
if [[ ! -f "utilization-timeseries.eps" ]]; then
  echo "utilization-timeseries.eps not found!"
  exit 1
fi
ls *.eps | xargs --max-lines=1 epspdf
convert -density 150  utilization-timeseries.pdf utilization-timeseries.png

fs=`find . -name '*.eps'`
if [ -z "$fs" ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi

