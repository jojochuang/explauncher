set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set xrange [0:100]
set autoscale xmax

set ylabel "Time (usec)" font "Helvetica,22" tc lt 1

set key left top 

set xlabel "Run" font "Helvetica,22"
set output "result/avg-latency.eps"

set style histogram gap 2
set style data histogram
set style fill solid border -1 
plot \
  'data/avg-throughput.ts' using 1 title "Average" linecolor rgb "#FF0000"

