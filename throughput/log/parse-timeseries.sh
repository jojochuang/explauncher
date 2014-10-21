#!/bin/bash

logdir=/u/tiberius06_s/chuangw/logs/throughput
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
  # find the latest log dir
  dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
  # find the latest log set in the dir
  headfile=(`find $dir -name 'head-*.gz' | tail -1`)
  clifile=(`find $dir -name '*player*.gz'`)
  svfile=(`find $dir -name 'server-*.gz'`)
else
  dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
  headfile=(`find $dir -name 'head*.gz' | tail -1`)
  clifile=(`find $dir -name '*player*.gz'`)
  nsfile=(`find $dir -name '*.nserver.conf' | tail -1`)
  #headfile=(`find ./ -name '*head*.gz' | grep "migration" | sort`)
  cutoff=220000000
fi
#file=(`find ./ -name '*head*.gz' | grep "migration-n2-c8" | sort | tail -1`)

start_time=0
# For headfile, generate plot file
for f in "${headfile[@]}"; do
  echo "head = $f"

  start_time_us=`zgrep -a -e "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  start_time=$(($start_time_us / 1000000))

  #prejoin_time=`zgrep -a -e "PREJOIN_WAIT_TIME" $f | head -1 | awk '{print $5}' | tr -d '"\r\n'`

  #echo "prejoin = $prejoin_time"

  # throughput
  out="${cwd}/data/head-throughput.ts"
  echo "producing $out"
  zgrep -a -e "EVENT_FINISH" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

  # migration
  #out="${cwd}/data/head-migration.ts"
  #echo "producing $out"
  #zgrep -a -e "MIGRATION_EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

  # num_players
  #out="${cwd}/data/head-nplayers.ts"
  #echo "producing $out"
  #if [[ "$type" = "instant" ]]; then
  #  zgrep -a -e "num_kids" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time) printf \"%.3f\t%d\n\", (T/1000000), \$3}" | sort -k +1n > $out
  #else
  #  zgrep -a -e "num_kids" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time+1000000 && T < $cutoff) printf \"%.3f\t%d\n\", (T/1000000), \$3}" | sort -k +1n > $out
  #fi

done

# For svfile, generate plot file
# assuming timers on all machines are all sync'ed.
for f in "${svfile[@]}"; do
  echo "server file = $f"

  #start_time_us=`zgrep -a -e "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  #start_time=$(($start_time_us / 1000000))

  #prejoin_time=`zgrep -a -e "PREJOIN_WAIT_TIME" $f | head -1 | awk '{print $5}' | tr -d '"\r\n'`

  #echo "prejoin = $prejoin_time"

  # throughput
  out="${cwd}/data/head-throughput.ts"
  echo "producing $out"
  zgrep -a -e "EVENT_FINISH" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n >> $out

  # migration
  #out="${cwd}/data/head-migration.ts"
  #echo "producing $out"
  #zgrep -a -e "MIGRATION_EVENT_COMMIT" $f | awk "{ T=int(\$1 - $start_time); print T\"\t\"\$5}" | sort -k +1n > $out

  # num_players
  #out="${cwd}/data/head-nplayers.ts"
  #echo "producing $out"
  #if [[ "$type" = "instant" ]]; then
  #  zgrep -a -e "num_kids" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time) printf \"%.3f\t%d\n\", (T/1000000), \$3}" | sort -k +1n > $out
  #else
  #  zgrep -a -e "num_kids" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time+1000000 && T < $cutoff) printf \"%.3f\t%d\n\", (T/1000000), \$3}" | sort -k +1n > $out
  #fi

done

${cwd}/aggregator.pl $out

if [[ "$type" = "publish" ]]; then
  # For nserver file
  for f in "${nsfile[@]}"; do
    echo "nserver = $f"
    out="${cwd}/data/head-nservers.ts"
    echo "producing $out"
    zgrep -a -e " num_servers" $f | awk "{ T=int(\$3); printf \"%.3f\t%d\n\", (T/1000000), \$4}" > $out
  done
fi


# For clifile, generate plot file
out="${cwd}/data/client-latency-tmp.ts"
echo "producing $out"
rm $out

for f in "${clifile[@]}"; do
  echo "client = $f"
  #i="${f%%.*}"
  #i=`basename "$i"`
  #echo $i

  #start_time_us=`zgrep -a -e "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  #start_time=$(($start_time_us / 1000000))

  if [[ "$type" = "instant" ]]; then
    zgrep -a -e "latency" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time) printf \"%.1f\t%.3f\n\", (T/1000000), (\$3/1000)}" >> $out
    #zgrep -a -e "EVENT_COMMIT_COUNT" $f
  else
    zgrep -a -e "latency" $f | awk "{ T=int(\$1 - $start_time_us); if (T>$prejoin_time+1000000 && T < $cutoff) printf \"%.1f\t%.3f\n\", (T/1000000), (\$3/1000)}" >> $out
    #zgrep -a -e "EVENT_COMMIT_COUNT" $f
  fi

  #grep "" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./microbenchmark.awk | sort -t' ' -k +1n -k +2n > result-${i}.dat
  #cat result-${i}.dat
  #echo ""
done


# Process the file
newout="${cwd}/data/client-latency.ts"
echo "producing $newout"

#cat $out | $cwd/timeseries.awk | sort -k +1n > $newout
cat $out | sort -k +1n | ${cwd}/sma.awk P=50 > $newout
#rm $out


