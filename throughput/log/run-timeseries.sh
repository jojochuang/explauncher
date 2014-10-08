#!/bin/bash

app="microbenchmark"

#logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/run10-various-halfmigrate-longrun/
logdir=/u/tiberius06_s/yoo7/logs/tag
#type="migration_before_and_after"
#type="tag"
type="instant"
#type="publish"

# We need a better plot parser

#./parse-timeseries.sh $logdir > data/timeseries.dat

#cat data/timeseries.dat | ./timeseries.awk | ./sma.awk > data/timeseries-plot.dat
#cat result-plot.dat | ./${app}-plot.awk > ${app}-plot.dat

if [[ "$type" = "publish" ]]; then
  echo "generating publish"
  logdir=/u/tiberius06_s/yoo7/logs/tag_archive/final01-migration
  #logdir=/u/tiberius06_s/yoo7/logs/tag_archive/final02
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-latency-publish.plot
  #gnuplot < timeseries-throughput.plot
  #gnuplot < timeseries-migration.plot
elif [[ "$type" = "instant" ]]; then
  logdir=/u/tiberius06_s/yoo7/logs/tag
  echo "generating instant"
  ./check-assert.sh $type $logdir
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure."
    #exit 0
  fi
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-latency.plot
  gnuplot < timeseries-throughput.plot
  gnuplot < timeseries-migration.plot
fi



#if [[ "$type" = "tag" ]]; then
  #echo "generating before-and-after"
  #logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final04-migration-timeseries-varying-context
  #./parse-timeseries.sh $type $logdir
  #gnuplot < timeseries-before-and-after.plot
#elif [[ "$type" = "migration_scale_out_and_in" ]]; then
  #echo "generating scale-out-and-in"
  #./parse-timeseries.sh $type $logdir
  #gnuplot < timeseries-scale-out-and-in.plot
#else
  #echo "generating instant"
  #./parse-timeseries.sh $type $logdir
  #gnuplot < timeseries-instant.plot
#fi



cd result
ls *.eps | xargs --max-lines=1 epspdf
#epspdf tag-latency.eps
#epspdf tag-throughput.eps
#epspdf tag-migration.eps
#epspdf tag-nserver.eps
rm *.eps
#mv timeseries.pdf result
#rm *.eps *.pdf


