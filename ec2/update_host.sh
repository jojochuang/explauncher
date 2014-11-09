#!/bin/bash
if [[ $# -lt 1 ]]; then
  echo "need one parameter: application name"
  exit
fi
application=$1
source ../common.sh

if [ -z $ACCESS_KEY ] && [ -z $SECRET_KEY ]; then
  ec2din  | grep INSTANCE > /tmp/inst
else
  ec2din  -O $ACCESS_KEY -W $SECRET_KEY | grep INSTANCE > /tmp/inst
fi
cat /tmp/inst | awk '{if( $6 == "running" ){print $5}}'| grep -v `hostname` > /tmp/hosts

cat /tmp/hosts
nl=`wc /tmp/hosts`
echo "===${nl} nodes==="
echo "sure to overwrite hosts of application ${application}? (y/N)"
read ans
echo $ans

if [[ $ans == 'y' ]]; then
  echo "answer is yes"
  cp /tmp/hosts ../${application}/conf/hosts
else
  echo "answer is no. give up" 
fi
