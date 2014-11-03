#!/bin/bash

application="throughput"
source ../../common.sh

type="instant"

if [[ "$type" = "publish" ]]; then
  echo "generating publish"
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-latency-publish.plot
elif [[ "$type" = "instant" ]]; then
  echo "generating instant"
  # check for assertion failures in the latest logs
  ./check-assert.sh $type $logdir
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure."
    #exit 0
  fi
  # generate data points from the log
  ./parse-timeseries.sh $type $logdir
  # generate eps plot using the data points
  gnuplot < timeseries-throughput-combined.plot
fi

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
rm *.eps

