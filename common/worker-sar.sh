#!/bin/bash

dir=$1
name=$2
interval=$3
runtime=$4

function thread () {
    mkdir -p $dir
    screen -d -m -S sarscreen sar -o $dir/$name $interval $runtime
}

thread
echo "Running sar with logname = ${name}"
disown -a
exit 0
