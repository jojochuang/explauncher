#!/bin/bash
application="throughput"
$label=$1
source ../common.sh
echo $ec2

# find the latest log
echo $logdir
last_log_dir=`ls -tr ${logdir} | tail -n1`
echo $last_log_dir
logfiles=(`find ${logdir}/$last_log_dir -regex '.*\(server\|client\|head\).*gz'`)
echo $logfiles

rm /tmp/connection_log
for f in "${logfiles[@]}"; do
  echo $f
  zgrep -e "\(TcpTransport::connect\|BaseTransport::BaseTransport\)" $f > /tmp/nacho_log 
  ./log/parse-connection.pl /tmp/nacho_log   >> /tmp/connection_log
done
./log/genplot-connection.pl /tmp/connection_log conf/boot conn.dot
neato -Tpdf conn.dot -o conn$1.pdf
