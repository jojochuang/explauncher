
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
set key right bottom

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
set output "result/timeseries.eps"

#set arrow 1 from 171,29000 to 165,31000 lt 1 lw 3
#set label 1 "Migration for all context" at 151,28500 tc rgb "#ff0000"

#set arrow 2 from 360,970 to 360,1170 lt 1 lw 3
#set label 2 "From 2 to 4 nodes" at 250,920 tc rgb "#ff0000"

plot \
  'data/instant.ts'    using 1:($2) title "result"   lt -1 pt 0 lw 1
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
