#!/bin/bash

application="ranger"
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
./parse-timeseries.sh $type $logset
# generate eps plot using the data points
gnuplot < timeseries-throughput-combined.plot

rm data/server*.ts
rm data/head*.ts

# generate pdf files using the eps file.
cd result
if [[ ! -f "throughput.eps" ]]; then
  echo "throughput.eps not found!"
  exit 1
fi
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps
rm *.eps

