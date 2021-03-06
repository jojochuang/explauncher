#!/bin/bash
source conf/conf.sh
source ../common.sh
echo "start stat-utilization.sh"
label=$1
input_util="data/all_raw_cpu.ts"
output="data/stat-utilization.ts"
if [ -f $input_util ]; then
  avg_util=`awk 'BEGIN{sum=0} {sum+=(100-$1); array[NR]=(100-$1)} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print sum/NR " " sqrt(sumsq/NR)}' $input_util`
  echo "$label $avg_util" >> $output
  echo "Average CPU Utilization is $avg_util %"
else
  echo "No sar log. Can't compute average CPU Utilization"
fi

# plot
# generate eps plot using the data points
gnuplot < $plotter/stat-utilization.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
#mogrify -format png *.eps
convert -density 150  stat-utilization.pdf stat-utilization.png
fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi

echo "end stat-utilization.sh"
