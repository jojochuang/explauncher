set border 3
set xtics nomirror rotate by -45
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set xrange [0:1000]
set autoscale xmax

set ylabel "Time (usec)" font "Helvetica,22" tc lt 1

set key right top 

set xlabel "Configuration" font "Helvetica,22"
set output "result/stat-latency.eps"

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

set grid ytics

plot \
  'data/stat-latency.ts' using 2:3:xtic(1) with histogram title "Mean", \
  '' using 4:xtic(1) ls 1 with linespoints title "Median" , \
  '' using 5:xtic(1) ls 2 with linespoints title "90%th percentile"
