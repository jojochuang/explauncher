set border 3
set xtics nomirror
set ytics nomirror
set y2tics
set terminal postscript enhanced eps color "Helvetica" 22

set yrange [0:100]
set autoscale ymax

set xrange [0:10000]
#set autoscale xmax

set ylabel "C.D.F." font "Helvetica,22" tc lt 1
set y2label "Frequency" font "Helvetica,22" tc lt 1

set key left top 

set xlabel "Round-trip latency (usec)" font "Helvetica,22"
set output "result/put-latency.eps"

set style histogram gap 1
set style data histogram
set style fill solid border -1 

bw = 100
bin(x,width)=width*floor(x/width)
x=system("wc data/put-latency.ts|awk '{print $1}'")


plot \
  'data/put-latency.ts' using (bin($1,bw)):(1.0) title "Put request" smooth frequency with boxes axis x1y2, \
  '' using (bin($1,bw)):( 1.0/x ) title "Cumulative" smooth cumulative axis x1y1 
