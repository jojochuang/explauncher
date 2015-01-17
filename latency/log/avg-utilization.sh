#!/bin/bash
input_util="data/utilization.ts"
if [ -f $input_util ]; then
  avg_util=`awk 'BEGIN{sum=0} {sum+=$1} END{print (sum/NR) }' $input_util`
  echo "Average CPU Utilization is $avg_util %"
else
  echo "No sar log. Can't compute average CPU Utilization"
fi
