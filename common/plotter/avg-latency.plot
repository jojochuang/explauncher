set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set xrange [0:1000]
set autoscale xmax

set ylabel "Time (usec)" font "Helvetica,22" tc lt 1

set key right top 

set xlabel "Run" font "Helvetica,22"
set output "result/avg-latency.eps"

set style histogram gap 1
set style histogram errorbars gap 2 lw 2
set style data histogram
set style fill solid border -1 

set style data linespoints
#set style line linewidth 2 pointtype 7 point size 2  
#set style line pt 7 point size 2
set style line 1 lt 2 lc rgb "red" lw 3 pt 7 ps 2
set style line 2 lt 2 lc rgb "orange" lw 2 pt 7 ps 2
set style line 3 lt 2 lc rgb "yellow" lw 3 pt 7 ps 2
set style line 4 lt 2 lc rgb "blue" lw 3 pt 7 ps 2
set style line 5 lt 2 lc rgb "purple" lw 3 pt 7 ps 2

#plot \
#  newhistogram "GET", 'data/avg-latency.ts' every 2::0 using 2:3:xtic(1) title "Latency" with linespoints linecolor rgb "#0000FF", \
#  newhistogram "PUT", 'data/avg-latency.ts' every 2::1 using 2:3:xtic(1) title "Latency" with linespoints linewidth 2 pointtype 7 point size 2linecolor rgb "#FF0000"
#

set grid ytics

plot \
  'data/avg-latency.ts' every 2::0 using 2:3:xtic(1) with histogram title "Mean", \
  '' every 2::0 using 4:xtic(1) ls 1 with linespoints title "Median" , \
  '' every 2::0 using 5:xtic(1) ls 2 with linespoints title "90%th percentile", \
  '' every 2::1 using 2:3:xtic(1) with histogram title "Mean", \
  '' every 2::1 using 4:xtic(1) ls 3 with linespoints title "Median" , \
  '' every 2::1 using 5:xtic(1) ls 4 with linespoints title "90%th percentile"
