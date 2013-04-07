#!/bin/bash

logdir=/u/tiberius06_s/yoo7/logs/tag
cwd=`pwd`
#echo $cwd

if [[ $# -ge 2 ]]; then
  type=$1
  logdir=$2
fi

echo $logdir
cd $logdir

if [[ "$type" = "instant" ]]; then
  dir=`ls -t | sed /^total/d | head -1 | tr -d '\r\n'`
  files=(`find $dir -name '*.log.gz'`)
  echo $dir
fi

#cd $dir
#pwd

retcode=0

for f in "${files[@]}"; do
  #echo "file = $f"
  
  r=`zgrep -a -e "Assert" $f`
  if [[ ${#r} -ge 2 ]]; then
    echo -e "\e[00;31m${f}:\e[00m $r"
    #echo $f
    #echo $r
    retcode=1
  fi
done
#for (( i=0; i<${#r[@]}; i++ )); do
  #echo ${r[$i]}
#done
#echo $r
#if [[ ${#r[@]} -gt 0 ]]; then
  #exit 1
#else
  #exit 0
#fi

exit $retcode

