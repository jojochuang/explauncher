
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
set output "microbenchmark-plot.eps"

#set arrow 1 from 180,435 to 180,635 lt 1 lw 3
#set label 1 "From 1 to 2 nodes" at 100,380 tc rgb "#ff0000"

#set arrow 2 from 360,970 to 360,1170 lt 1 lw 3
#set label 2 "From 2 to 4 nodes" at 250,920 tc rgb "#ff0000"

plot \
  'microbenchmark-plot.dat'    using 1:($2) title "Nodes"   lt -1 pt 0 lw 1

