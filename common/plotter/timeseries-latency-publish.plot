
#set bmargin 5


#set border 3
set xtics nomirror
set ytics nomirror
set y2tics tc lt 1
set terminal postscript enhanced eps color "Helvetica" 22

set autoscale

set ylabel "Number of clients" font "Helvetica,22"
set y2label "Average client latency (ms)" font "Helvetica,22" tc lt 1
#set y2label "Head node throughput (evt/sec)" font "Helvetica,22" tc lt 1

#set ytics 0,.25,1
#set xrange [0:200]
#set mytics 5
set xrange [0:200]
set yrange [0:80]
set style data linesp
#set key above box
set key right top 

#unset key

# Items : {Lxc/NoLxc}, {Noalive/Tcpalive}, {Nofail/Killonce/Rolling}
# Measures : {CDF}


# Compare : {Lxc}, {Nofail}
# Measures : {Noalive/Tcpalive}

#unset key

set xlabel "Time (sec)" font "Helvetica,22"
set output "result/tag-latency.eps"

set arrow 1 from 50,65 to 32,50 lt 1 lw 3
set arrow 2 from 65,65 to 68,55 lt 1 lw 3
set arrow 3 from 80,65 to 105,55 lt 1 lw 3

set label 1 "No migrations" at 40,68 tc rgb "#ff0000"

set arrow 4 from 165,62 to 150,55 lt 1 lw 3
set arrow 5 from 172,62 to 190,55 lt 1 lw 3

set label 2 "Migrations" at 150,65 tc rgb "#ff0000"

plot \
  'data/head-nplayers.ts'    using 1:($2) title "number of clients"   lt -1 pt 0 lw 0.3, \
  'data/client-latency.ts'    using 1:($2) title "latency"   lt 1 pt 0 lw 1 axes x1y2
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

unset key
unset ylabel
unset y2label
unset y2tics
unset yrange
set autoscale
set xrange [0:200]
set yrange [0:10]
set xtics nomirror
set ytics nomirror

set xlabel "Time (sec)" font "Helvetica,22"
set ylabel "Number of servers" font "Helvetica,22"
set output "result/tag-nserver.eps"


plot \
  'data/head-nservers.ts'    using 1:($2) title "number of servers"   lt -1 pt 0 lw 0.3




