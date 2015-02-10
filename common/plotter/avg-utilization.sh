#!/bin/bash
label=$1
input_util="data/utilization.ts"
output="data/stat-utilization.ts"
if [ -f $input_util ]; then
  #avg_util=`awk 'BEGIN{sum=0} {sum+=$1} END{print (sum/NR) }' $input_util`
  avg_util=`awk 'BEGIN{sum=0} {sum+=$1; array[NR]=$1} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))**2);}print sum/NR " " sqrt(sumsq/NR)}' $input_util`
  echo "$label $avg_util" >> $output
  echo "Average CPU Utilization is $avg_util %"
else
  echo "No sar log. Can't compute average CPU Utilization"
fi

# plot
# generate eps plot using the data points
gnuplot < avg-utilization.plot

# generate pdf files using the eps file.
cd result
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps
#rm *.eps

#for f in "*.eps"; do
#  rm $f
#done
fs=`find . -name '*.eps'`
if [ -z $fs ]; then
  echo "no *.eps found in ./"
else
  rm $fs
fi
