#!/bin/bash

logdir=/u/tiberius06_s/yoo7/logs/microbenchmark

if [[ $# -ge 1 ]]; then
    logdir=$1
fi

cd $logdir
#pwd

#file=(`find ./ -name '*head*' | grep payload | xargs zgrep -l execution_time | sort`)
file=(`find ./ -name '*head*' | xargs zgrep -l execution_time | sort`)

#echo -e "TYPE\tID\tNUM_MACHINES\tNCONTEXT\tNPRIME\tNEVENT\tTIME\tNUM_COMMIT"
#microbenchmark-context-default-n1-c1-p1-e10000-20130313-16-35-52

for f in "${file[@]}"; do
  echo $f | awk -F'-' '{printf "\n"$2" "$3}'
  echo $f | awk -F'-' '{printf " "$4" "$5" "$6" "$7" "$8" "}' | tr -d 'ncpel'
  zgrep -a -e "MIGRATION_EVENT_LIFE_TIME" $f | tail -1 | awk '{printf $4" "}'
  zgrep -a -e "MIGRATION_EVENT_COMMIT" $f | tail -1 | awk '{printf $4}'
done

