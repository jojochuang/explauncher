#!/bin/bash

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
# generate data points from the log
$plotter/parse-latency.sh $logset
#exit 0
# generate eps plot using the data points
gnuplot < $plotter/get-latency.plot
gnuplot < $plotter/put-latency.plot

#rm data/get-latency.ts
#rm data/put-latency.ts

# generate pdf files using the eps file.
cd result
if [[ ! -f "get-latency.eps" ]]; then
  echo "get-latency.eps not found!"
  exit 1
fi
if [[ ! -f "put-latency.eps" ]]; then
  echo "put-latency.eps not found!"
  exit 1
fi

ls *.eps | xargs --max-lines=1 epspdf
#mogrify -format png *.eps
convert -density 150  get-latency.pdf get-latency.png
convert -density 150  put-latency.pdf put-latency.png
rm *.eps

