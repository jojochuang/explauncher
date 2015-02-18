
#set bmargin 5


set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22
#set size ratio -3

# Get latency's range
#plot "data/client-latency.ts" u 1:2
#set yrange [0:GPVAL_Y_MAX]
#set ytics 0,1000,GPVAL_Y_MAX
set yrange [0:20000]
#set ytics 0,5000,50000

#plot "data/head-nplayers" u 1:2
#set y2range [0:GPVAL_Y_MAX]
#set y2tics 0,1,GPVAL_Y_MAX
#set y2range [0:100]
#set y2tics 0,10,100

#set autoscale xmax
set xrange [0:200]
#set autoscale 

#set ylabel "Number of players" font "Helvetica,22"
set ylabel "Latency (us)" font "Helvetica,22" tc lt 1

#set ytics 0,.25,1
#set xrange [0:200]
#set mytics 5
set style data linesp
set key right  bottom

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

set xlabel "Time (sec)" font "Helvetica,22"
#set output "result/combined-latency-timeseries.eps"
set output "result/combined-latency.eps"

start_time=system("head -n1 data/combined-latency.ts|awk '{print $1}'")

set multiplot

#  set horizontal margins for second column
set lmargin at screen 0.1
set rmargin at screen 0.9
#  set horizontal margins for first row (bottom)
set tmargin at screen 0.05
set bmargin at screen 0.45
plot \
'/home/ubuntu/benchmark/kvmigration/data/combined-latency.ts'    using ($1-start_time):($2) title "combined latency"   lt 1 pt 0 lw 3 axes x1y1

#set y2tics tc lt 1
#set y2range [0:8]
set yrange [0:8]
#set autoscale ymax
#  set horizontal margins for second column
set lmargin at screen 0.1
set rmargin at screen 0.9
#  set horizontal margins for first row (bottom)
set tmargin at screen 0.55
set bmargin at screen 0.95
set ylabel "# server physical nodes" font "Helvetica,22" tc lt 1
plot \
'/home/ubuntu/benchmark/kvmigration/data/scale_server.ts'    using ($2/1000000):($4) title "server scale"   lt 2 pt 0 lw 3 axes x1y1

unset multiplot
