#!/bin/bash

logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/run10-various-halfmigrate-longrun/
#pushd $logdir
cd $logdir

# Which file do you want to plot?
#file=(`find ./ -name '*head*.gz' | grep "migration" | sort | tail -1`)
file=(`find ./ -name '*head*.gz' | grep "migration-n2-c8" | sort | tail -1`)


# Per each file, generate plot

for f in "${file[@]}"; do
  #echo $f
  id1=`echo $f | awk -F'-' '{printf $2" "$3}' | tr -d '\n'` 
  id2=`echo $f | awk -F'-' '{printf $4" "$5" "$6" "$7}' | tr -d 'ncpe\n'`
  #echo "$id1 $id2"
  zgrep -a -e "EVENT_READY_COMMIT" $f | awk "{printf \"$id1 $id2 \"; printf \$1\" \"\$4\" \"\$5; printf \"\n\" }"
  #zgrep -a -e "EVENT_COMMIT_COUNT" $f

  #grep "" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./microbenchmark.awk | sort -t' ' -k +1n -k +2n > result-${i}.dat
  #cat result-${i}.dat
  #echo ""
done


