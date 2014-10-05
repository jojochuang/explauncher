app="microbenchmark"

#logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/run10-various-halfmigrate-longrun/
#logdir=/u/tiberius06_s/yoo7/logs/microbenchmark
logdir=/home/ubuntu/logs/microbenchmark
#type="migration_before_and_after"
#type="migration_scale_out_and_in"
type="instant"

# We need a better plot parser

#./parse-timeseries.sh $logdir > data/timeseries.dat

#cat data/timeseries.dat | ./timeseries-sum.awk | ./sma.awk > data/timeseries-plot.dat
#cat result-plot.dat | ./${app}-plot.awk > ${app}-plot.dat

if [[ "$type" = "migration_before_and_after" ]]; then
  echo "generating before-and-after"
  logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final04-migration-timeseries-varying-context
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-before-and-after.plot
elif [[ "$type" = "migration_scale_out_and_in" ]]; then
  echo "generating scale-out-and-in"
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-scale-out-and-in.plot
else
  echo "generating instant"
  ./check-assert.sh $type $logdir
  if [[ $? -ne 0 ]]; then
    echo "There is assertion failure."
    #exit 0
  fi
  ./parse-timeseries.sh $type $logdir
  gnuplot < timeseries-instant.plot
fi



cd result
#epspdf migration-before-and-after-0.eps
#epspdf migration-before-and-after-100.eps
ls *.eps | xargs --max-lines=1 epspdf
#epspdf timeseries.eps
#rm *.eps
#mv timeseries.pdf result
#rm *.eps *.pdf


