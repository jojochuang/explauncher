#!/bin/bash

logdir=/u/tiberius06_s/yoo7/logs/microbenchmark

#pushd $logdir
cd $logdir

file=(`find ./ -name '*head*' | xargs zgrep -l execution_time | sort`)

#echo -e "TYPE\tID\tNUM_MACHINES\tNCONTEXT\tNPRIME\tNEVENT\tTIME\tNUM_COMMIT"
#microbenchmark-context-default-n1-c1-p1-e10000-20130313-16-35-52

for f in "${file[@]}"; do
  #echo $f
  echo $f | awk -F'-' '{printf "\n"$2" "$3}'
  #echo $f | awk -F'-' '{printf "\t"$3"\t"$5"\t"$6"\t"$7"\t"}' | tr -d 'ncve'
  echo $f | awk -F'-' '{printf " "$4" "$5" "$6" "$7" "}' | tr -d 'ncpe'
  zgrep -e "execution_time" $f | tail -1 | awk '{printf $4" "}'
  zgrep -e "EVENT_COMMIT_COUNT" $f | tail -1 | awk '{printf $4}'
done

#popd

