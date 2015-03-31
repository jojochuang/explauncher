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

function gen_distribution () {
  type="instant"

  # check for assertion failures in the latest logs
  $plotter/check-assert.sh $type ${logset}
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure."
  fi
  # generate distribution of latency from the log
  $plotter/parse-latency.sh $logset
  # generate eps plot using the data points
  gnuplot < $plotter/get-latency.plot
  gnuplot < $plotter/put-latency.plot

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
  convert -density 150  get-latency.pdf get-latency.png
  convert -density 150  put-latency.pdf put-latency.png
  rm *.eps

  cd ..
}

function gen_timeseries_plot () {
    request=$1
    gnuplot < $plotter/latency-$request-timeseries-combined.plot

    # generate pdf files using the eps file.
    cd result
    if [[ ! -f "${request}-latency-timeseries.eps" ]]; then
      echo "${request}-latency-timeseries.eps not found!"
      exit 1
    fi

    ls *.eps | xargs --max-lines=1 epspdf
    #mogrify -format png *.eps
    convert -density 150  $request-latency-timeseries.pdf $request-latency-timeseries.png
    rm *.eps
    
    cd ..

    # plot both number of servers and latency timeseries in one figure
    gnuplot < $plotter/all-latency-${request}-timeseries.plot

    # generate pdf files using the eps file.
    cd result
    if [[ ! -f "combined-${request}-latency.eps" ]]; then
      echo "combined-${request}-latency.eps not found!"
      exit 1
    fi

    ls *.eps | xargs --max-lines=1 epspdf
    #mogrify -format png *.eps
    convert -density 150  combined-${request}-latency.pdf combined-${request}-latency.png
    rm *.eps
    cd ..
}

gen_distribution
gen_timeseries_plot "put"
gen_timeseries_plot "get"
