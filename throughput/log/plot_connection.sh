#!/bin/bash
application="throughput"
label=$1
source ../../common.sh

# find the latest log set
echo $logdir
last_log_set=`ls -tr ${logdir} | tail -n1`
echo $last_log_set
#logfiles=(`find ${logdir}/$last_log_set -regex '.*\(server\|client\|head\).*gz'`)

last_log_dir=`ls -tr ${logdir}/${last_log_set} | tail -n1`
echo $last_log_dir
logfiles=(`find ${logdir}/${last_log_set}/${last_log_dir} -regex '.*\(server\|client\|head\).*gz'`)

echo $logfiles

rm /tmp/connection_log
for f in "${logfiles[@]}"; do
  echo $f
  zgrep -e "\(TcpTransport::connect\|BaseTransport::BaseTransport\)" $f > /tmp/nacho_log 
  ./parse-connection.pl /tmp/nacho_log   >> /tmp/connection_log
done
./genplot-connection.pl /tmp/connection_log conf/boot data/conn.dot
neato -Tpdf data/conn.dot -o result/conn_$label.pdf
neato -Tpng data/conn.dot -o result/conn_$label.png
