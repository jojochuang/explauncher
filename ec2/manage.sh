#!/bin/bash

source conf/config.sh

# instance_id is the master node that you'll be controlling other machines.
# Make sure you start it, and connect to the node so that you can do whatever you want to do.

if [ $# -eq 0 ]; then
  echo "usage : mange.sh [connect|stop|start]"
  action="connect"
else
  action=$1
fi
#echo $id
#echo $id

if [ "$action" = "connect" ]; then
  host=`ec2din -O $ACCESS_KEY -W $SECRET_KEY $instance_id | grep "INSTANCE" | awk '{print $4}'`
  echo "ssh -i $pem_file ubuntu@$host"
elif [ "$action" = "stop" ]; then
  echo "stopping"
  ec2stop -O $ACCESS_KEY -W $SECRET_KEY $instance_id
elif [ "$action" = "start" ]; then
  echo "starting"
  ec2start -O $ACCESS_KEY -W $SECRET_KEY $instance_id
fi

