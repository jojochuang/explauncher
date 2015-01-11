#!/bin/bash
#set -e

source ../conf/conf.sh
source ../../common.sh

if [[ $# -lt 1 ]]; then
  logset=`ls -trd ${logdir}/${application}-* | tail -n1`
else
  logset=$1
fi 

echo "logdir=$logdir"
echo "logset=$logset"

type="instant"

# check for assertion failures in the latest logs
./check-assert.sh $type ${logset}
if [[ $? -ne 0 ]]; then
  echo "There is assertion failure."
  #exit 0
fi

# generate data points from the log
./parse-network-timeseries.sh $type $logset
# generate eps plot using the data points
gnuplot < net-write-timeseries-combined.plot
gnuplot < net-read-timeseries-combined.plot

fs=`find data/ -name 'net-*.ts'`
if [ -z "$fs" ]; then
  echo "no net-*.ts found in data/"
else
  rm $fs
fi
#for f in "data/server*.ts"; do
#  rm $f
#done
#fs=`find data/ -name 'data*.ts'`
#if [ -z $fs ]; then
#  echo "no server*.ts found in data/"
#else
#  rm $fs
#fi
#for f in "data/head*.ts"; do
#  rm $f
#done
#rm data/server*.ts
#rm data/head*.ts

# generate pdf files using the eps file.
cd result
if [[ ! -f "net-write.eps" ]]; then
  echo "net-write.eps not found!"
  exit 1
fi
if [[ ! -f "net-read.eps" ]]; then
  echo "net-read.eps not found!"
  exit 1
fi
ls *.eps | xargs --max-lines=1 epspdf
mogrify -size 640x480 -format png *.eps
#rm *.eps

#for f in *.eps; do
#  rm $f
#done
fs=`find . -name '*.eps'`
if [ -z "$fs" ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
