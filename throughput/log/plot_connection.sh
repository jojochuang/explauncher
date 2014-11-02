#!/bin/bash
application="throughput"
source ../common.sh
echo $ec2

# find the latest log
echo $logdir
last_log_dir=`ls -tr ${logdir} | tail -n1`
echo $last_log_dir
logfiles=(`find ${logdir}/$last_log_dir -regex '.*\(server\|client\|head\).*gz'`)
echo $logfiles

echo "digraph Connection {" > conn.dot
for f in "${logfiles[@]}"; do
  echo $f
  zgrep -e "\(TcpTransport::connect\|BaseTransport::BaseTransport\)" $f > /tmp/connection_log 
  ./log/parse-connection.pl /tmp/connection_log  >> conn.dot
  #awk '{print $6 $10 $11 $12}'
done
echo "}" >> conn.dot
