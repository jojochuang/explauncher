#!/bin/bash

source ../conf/config.sh
source ../../common.sh
cwd=`pwd`

logset=`ls -trd ${logdir}/* | tail -n1`

cd $logset
echo "parse-service.sh: at $logset"
# Which file do you want to plot?

headfile=(`find . -name 'head-*.gz' | tail -1`)
echo "headfile = $headfile"

# throughput
out="${cwd}/data/head-sv.dot"
echo "producing $out"
zgrep -a -e "ServiceComposition::outputMaceout" $headfile | awk "{ if( \$3 ~ \"outputMaceout\" )print substr(\$0, 58)}"  > $out

