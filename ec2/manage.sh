#!/bin/bash

# instance_id is the master node that you'll be controlling other machines.
# Make sure you start it, and connect to the node so that you can do whatever you want to do.

instance_id="i-42849d3f"

if [ $# -eq 0 ]; then
  echo "usage : mange.sh [connect|stop|start]"
  action="connect"
else
  action=$1
fi
#echo $id
#echo $id

if [ "$action" = "connect" ]; then
  host=`ec2din -O AKIAIGXNKNV5WAFF2CWA -W kA1nDQ9KmnTf0DhiK9hxL39mUYA4Kb7s8rxHuc4V $instance_id | grep "INSTANCE" | awk '{print $4}'`
  echo "ssh ubuntu@$host"
elif [ "$action" = "stop" ]; then
  echo "stopping"
  ec2stop -O AKIAIGXNKNV5WAFF2CWA -W kA1nDQ9KmnTf0DhiK9hxL39mUYA4Kb7s8rxHuc4V $instance_id
elif [ "$action" = "start" ]; then
  echo "starting"
  ec2start -O AKIAIGXNKNV5WAFF2CWA -W kA1nDQ9KmnTf0DhiK9hxL39mUYA4Kb7s8rxHuc4V $instance_id
fi

