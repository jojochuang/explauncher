#!/bin/bash
source conf/conf.sh
source ../common.sh
label=$1

echo "start stat-latency.sh"

function compute_stat () {
    cwd=`pwd`
    # get statistics from all_raw_latency.ts
    allraw="${cwd}/data/all_raw_latency.ts"
    statlat="${cwd}/data/stat-latency.ts"

    sort -n $allraw -o $allraw
    # number of lines in 
    num_lines=`wc -l $allraw | cut -d" " -f1`
    # get the median number
    median_element=$(( $num_lines/2 ))
    # get average

    # get 90th percentile
    ninetyth=$(( $num_lines*9/10 ))

    awk -v vln="$label" -v me="$median_element" -v ne="$ninetyth" '{sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print vln " " sum/NR " " sqrt(sumsq/NR) " " array[me] " " array[ne] }' $allraw >> $statlat 

}

compute_stat 

gnuplot < $plotter/stat-latency.plot
cd result
epspdf stat-latency.eps
convert -density 150 stat-latency.pdf stat-latency.png
rm stat-latency.eps

echo "end stat-latency.sh"
