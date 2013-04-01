#!/bin/bash

logdir=/u/tiberius06_s/yoo7/logs/microbenchmark
cwd=`pwd`
#echo $cwd

if [[ $# -ge 2 ]]; then
  type=$1
  logdir=$2
fi

cd $logdir

# Which file do you want to plot?
#file=(`find ./ -name '*head*.gz' | grep "migration" | sort | tail -1`)
if [[ "$type" = "instant" ]]; then
  dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
  file=(`find $dir -name '*head*.gz' | tail -1`)
else
  file=(`find ./ -name '*head*.gz' | grep "migration" | sort`)
fi
#file=(`find ./ -name '*head*.gz' | grep "migration-n2-c8" | sort | tail -1`)


# Per each file, generate plot

for f in "${file[@]}"; do
  echo $f
  #i="${f%%.*}"
  #i=`basename "$i"`
  #echo $i

  start_time=`zgrep -a -e "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  start_time=$(($start_time / 1000000))
  #id1=`echo $f | awk -F'-' '{printf $2" "$3}' | tr -d '\n'` 
  #id2=`echo $f | awk -F'-' '{printf $4" "$5" "$6" "$7" "$8}' | tr -d 'ncpel\n'`
  if [[ "$type" = "migration_before_and_after" ]]; then
    id1=`echo $f | awk -F'-' '{printf $3"-"$8}'`
  elif [[ "$type" = "migration_scale_out_and_in" ]]; then
    id1=`echo $f | awk -F'-' '{printf $3"-"$8}'`
  else
    id1="instant"
  fi
  #echo "$id1 $id2"
  #zgrep -a -e "EVENT_READY_COMMIT" $f | awk "{printf \"$id1 $id2 \"; printf \$1\" \"\$4\" \"\$5; printf \"\n\" }" > $i.ts
  out="${cwd}/data/${id1}.ts"
  echo "producing $out"
  zgrep -a -e "EVENT_READY_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\" \"\$5}" | $cwd/sma.awk P=2 | sort -k +1n > $out
  #zgrep -a -e "EVENT_COMMIT_COUNT" $f

  #grep "" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./microbenchmark.awk | sort -t' ' -k +1n -k +2n > result-${i}.dat
  #cat result-${i}.dat
  #echo ""
done


