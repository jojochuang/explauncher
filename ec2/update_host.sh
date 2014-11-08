#!/bin/bash
if [[ $# -lt 1 ]]; then
  echo "need one parameter: application name"
  exit
fi
application=$1
source ../common.sh

ec2din  -O $ACCESS_KEY -W $SECRET_KEY | grep INSTANCE > /tmp/inst
cat /tmp/inst | awk '{if( $6 == "running" ){print $5}}'| grep -v `hostname` > /tmp/hosts

cat /tmp/hosts
echo "sure to overwrite hosts of application ${application}? (y/N)"
read ans
echo $ans

if [[ $ans == 'y' ]]; then
  echo "answer is yes"
  cp /tmp/hosts ../${application}/conf/hosts
else
  echo "answer is no. give up" 
fi
