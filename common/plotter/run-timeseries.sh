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

type="instant"

# check for assertion failures in the latest logs
$plotter/check-assert.sh $type ${logset}
if [[ $? -ne 0 ]]; then
  echo "There is assertion failure."
  #exit 0
fi
fs=`find data/ -name 'throughput-server*.ts'  -o -name 'throughput-head*.ts'`
if [ -z "$fs" ]; then
  echo "no throughput-{head,server}*.ts found in data/"
else
  rm $fs
fi
# generate data points from the log
$plotter/parse-timeseries.sh $type $logset
# generate eps plot using the data points
gnuplot < $plotter/timeseries-throughput-combined.plot

# generate pdf files using the eps file.
cd result
if [[ ! -f "throughput.eps" ]]; then
  echo "throughput.eps not found!"
  exit 1
fi
ls *.eps | xargs --max-lines=1 epspdf
convert -density 150  throughput.pdf throughput.png

fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
