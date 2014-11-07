#!/bin/bash

application="throughput"
source ../../common.sh

if [[ $# -lt 1 ]]; then
  logset=`ls -tr ${logdir} | tail -n1`
else
  logset=$1
fi 

type="instant"

# check for assertion failures in the latest logs
./check-assert.sh $type $logset
if [[ $? -ne 0 ]]; then
  echo "There is assertion failure."
  #exit 0
fi
# generate data points from the log
./parse-timeseries.sh $type $logset
# generate eps plot using the data points
gnuplot < timeseries-throughput-combined.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps
rm *.eps

