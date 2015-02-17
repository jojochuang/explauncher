
#set bmargin 5


set border 3
set xtics nomirror
set ytics nomirror
#set y2tics tc lt 1
set terminal postscript enhanced eps color "Helvetica" 22
#set size ratio -3

# Get latency's range
#plot "data/client-latency.ts" u 1:2
#set yrange [0:GPVAL_Y_MAX]
#set ytics 0,1000,GPVAL_Y_MAX
set yrange [0:10000]
#set ytics 0,5000,50000

#plot "data/head-nplayers" u 1:2
#set y2range [0:GPVAL_Y_MAX]
#set y2tics 0,1,GPVAL_Y_MAX
#set y2range [0:100]
#set y2tics 0,10,100

set autoscale xmax
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
set output "result/latency-timeseries.eps"

start_time=system("head -n1 data/column-latency.ts|awk '{print $1}'")

plot \
