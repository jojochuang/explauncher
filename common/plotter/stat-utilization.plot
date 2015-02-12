set border 3
set xtics nomirror rotate by -45
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set ylabel "Utilization (%)" font "Helvetica,22" tc lt 1
set key left top 

set xlabel "Configuration" font "Helvetica,22"
set output "result/stat-utilization.eps"
set style histogram errorbars gap 2 lw 2
set style data histogram
set style fill solid border -1 
plot \
  'data/stat-utilization.ts' using 2:3:xtic(1) title "Mango" linecolor rgb "#FF0000"

