
#set bmargin 5


set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22
set ylabel "Processed events (per sec)" font "Helvetica,22"
#set ylabel "NETWORK_WRITE (per sec)" font "Helvetica,22"
#set yrange [-.05:1.1]
#set ytics 0,.25,1
#set xrange [0:200]
set mytics 5
set style data linesp

# MaceKen:    circle, black
# Plain Mace: triangle, red
# get:    hollow, thin lines
# prior:  filled, thick lines

#unset key

# Items : {Lxc/NoLxc}, {Noalive/Tcpalive}, {Nofail/Killonce/Rolling}
# Measures : {CDF}


# Compare : {Lxc}, {Nofail}
# Measures : {Noalive/Tcpalive}

unset key

set xlabel "Time (sec)" font "Helvetica,22"
set output "result/timeseries.eps"

set arrow 1 from 171,29000 to 165,31000 lt 1 lw 3
set label 1 "Migration for all context" at 151,28500 tc rgb "#ff0000"

#set arrow 2 from 360,970 to 360,1170 lt 1 lw 3
#set label 2 "From 2 to 4 nodes" at 250,920 tc rgb "#ff0000"

plot \
  'data/timeseries-plot.dat'    using 1:($2) title "Nodes"   lt -1 pt 0 lw 1

