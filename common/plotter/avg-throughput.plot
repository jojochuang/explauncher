set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set xrange [0:100]
set autoscale xmax

set ylabel "Throughput (evt/sec)" font "Helvetica,22" tc lt 1

set key left top 

set xlabel "Run" font "Helvetica,22"
set output "result/avg-throughput.eps"

set style histogram gap 1
set style data histogram
set style fill solid border -1 

set grid ytics

plot \
  'data/avg-throughput.ts' using 6 title "Average" linecolor rgb "#FF0000"
