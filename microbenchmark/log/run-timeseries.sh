app="microbenchmark"

# We need a better plot parser

./parse-timeseries.sh > data/timeseries.dat

cat data/timeseries.dat | ./timeseries.awk | ./sma.awk > data/timeseries-plot.dat
#cat result-plot.dat | ./${app}-plot.awk > ${app}-plot.dat

gnuplot < timeseries.plot

cd result
epspdf timeseries.eps
#mv timeseries.pdf result
#rm *.eps *.pdf


