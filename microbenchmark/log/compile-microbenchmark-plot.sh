app="microbenchmark"

# We need a better plot parser

./plot-${app}.sh > result-plot.dat

cat result-plot.dat | ./${app}-plot.awk | ./sma.awk > ${app}-plot.dat
#cat result-plot.dat | ./${app}-plot.awk > ${app}-plot.dat

gnuplot < ${app}-plot.plot

epspdf microbenchmark-plot.eps


