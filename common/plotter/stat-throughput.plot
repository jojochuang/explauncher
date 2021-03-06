set border 3
set xtics nomirror rotate by -45
set ytics nomirror
#set y2tics tc lt 1
set terminal postscript enhanced eps color "Helvetica" 22

# Get latency's range
#plot "data/client-latency.ts" u 1:2
#set yrange [0:GPVAL_Y_MAX]
#set ytics 0,1000,GPVAL_Y_MAX
#set yrange [0:50000]
#set ytics 0,5000,50000

#plot "data/head-nplayers" u 1:2
#set y2range [0:GPVAL_Y_MAX]
#set y2tics 0,1,GPVAL_Y_MAX
#set y2range [0:100]
#set y2tics 0,10,100

set yrange [0:100]
set autoscale ymax

#set ylabel "Number of players" font "Helvetica,22"
set ylabel "Throughput (evt/sec)" font "Helvetica,22" tc lt 1

#set ytics 0,.25,1
#set xrange [0:200]
#set mytics 5
#set style data linesp
set key left top 

# MaceKen:    circle, black
# Plain Mace: triangle, red
# get:    hollow, thin lines
# prior:  filled, thick lines

#unset key

# Items : {Lxc/NoLxc}, {Noalive/Tcpalive}, {Nofail/Killonce/Rolling}
# Measures : {CDF}


# Compare : {Lxc}, {Nofail}
# Measures : {Noalive/Tcpalive}

#unset key

set xlabel "Configuration" font "Helvetica,22"
set output "result/stat-throughput.eps"
set grid ytics


set style histogram errorbars gap 1 lw 2
set style data histogram
set style fill solid border -1 
plot \
  'data/stat_throughput.ts' using 2:3:xtic(1) title "Random" linecolor rgb "#FF0000"
  #'data/stat_throughput.ts' using 2:3:xtic(1) title "Shifted" linecolor rgb "#FF0000", \
  #'data/stat_throughput.ts' using 5:6:xtic(4) title "Random" linecolor rgb "#00FF00", \
  #'data/stat_throughput.ts' using 8:9:xtic(7) title "Local" linecolor rgb "#0000FF"
