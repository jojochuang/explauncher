
#set bmargin 5


set border 3
set xtics nomirror
set ytics nomirror
set y2tics tc lt 1
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

set autoscale

set ylabel "Number of players" font "Helvetica,22"
set y2label "Head node throughput (evt/sec)" font "Helvetica,22" tc lt 1

#set ytics 0,.25,1
#set xrange [0:200]
#set mytics 5
set style data linesp
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

set xlabel "Time (sec)" font "Helvetica,22"
set output "result/tag-throughput.eps"

#set arrow 1 from 171,29000 to 165,31000 lt 1 lw 3
#set label 1 "Migration for all context" at 151,28500 tc rgb "#ff0000"

#set arrow 2 from 360,970 to 360,1170 lt 1 lw 3
#set label 2 "From 2 to 4 nodes" at 250,920 tc rgb "#ff0000"

plot \
  'data/head-nplayers.ts'    using 1:($2) title "number of players"   lt -1 pt 0 lw 0.3, \
  'data/head-throughput.ts'    using 1:($2) title "throughput"   lt 1 pt 0 lw 1 axes x1y2
  #'data/head-nplayers.ts'    using 1:($2) title "number of players"   lt 1 pt 0 lw 1 axes x1y2
  #'data/nocpu_migration_varying_context_size-l12800000.ts'    using 1:($2) title "S=12.8MB"   lt 1 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l25600000.ts'    using 1:($2) title "S=25.6MB"   lt 2 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l51200000.ts'    using 1:($2) title "S=51.2MB"   lt 3 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l100000.ts'    using 1:($2) title "S=0.1MB"   lt 1 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l200000.ts'    using 1:($2) title "S=0.2MB"   lt 2 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l400000.ts'    using 1:($2) title "S=0.4MB"   lt 3 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l800000.ts'    using 1:($2) title "S=0.8MB"   lt 4 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l1600000.ts'    using 1:($2) title "S=1.6MB"   lt 5 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l3200000.ts'    using 1:($2) title "S=3.2MB"   lt 6 pt 0 lw 1, \
  #'data/nocpu_migration_varying_context_size-l6400000.ts'    using 1:($2) title "S=6.4MB"   lt 7 pt 0 lw 1, \

