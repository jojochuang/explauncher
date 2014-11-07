#!/bin/bash

application="throughput"
source ../common.sh

# copy to cs website the logs, parameters:
#   boot, hosts-run, console.log, client log, server log,  parameter file, client/server console log
#   log/data/avg-throughput.ts, log/data/stat_throughput.ts
#   log/data/column-throughput.ts
#   log/result/throughput.pdf, log/result/stat-throughput.pdf/png
#   log/result/conn*.pdf

label=$1
#echo $ec2

webdir="/homes/chuangw/.www/benchmark/$application"

# find the latest log set
echo "logdir=${logdir}"
last_log_set=`ls -tr ${logdir} | tail -n1`
echo "last_log_set=${last_log_set}"
#logfiles=(`find ${logdir}/$last_log_set -regex '.*\(server\|client\|head\).*gz'`)

last_log_dir=`ls -tr ${logdir}/${last_log_set} | tail -n1`
#echo $last_log_dir
#logfiles=(`find ${logdir}/${last_log_set}/${last_log_dir} -regex '.*\(server\|client\|head\).*gz'`)

echo "copy log directory"
echo "cp -R ${logdir}/${last_log_set}/$last_log_dir ${webdir}/"
cp -R ${logdir}/${last_log_set}/$last_log_dir ${webdir}/${last_log_dir}
echo "copy column-throughput.ts"
cp log/data/column-throughput.ts ${webdir}/$last_log_dir
echo "copy stat_throughput.ts"
cp log/data/stat_throughput.ts ${webdir}/$last_log_dir
echo "copy avg-throughput.ts"
cp log/data/avg-throughput.ts ${webdir}/$last_log_dir
echo "copy conn.dot"
cp log/data/conn.dot ${webdir}/$last_log_dir

# find the latest connection graph
conn_graph=`ls -tr log/result/conn*.png | awk -F/ '{print $NF}' `
cp log/result/${conn_graph} ${webdir}/$last_log_dir
cp log/result/stat-throughput.png ${webdir}/$last_log_dir
cp log/result/throughput.png ${webdir}/$last_log_dir

#echo $logfiles

#rm /tmp/connection_log
#for f in "${logfiles[@]}"; do
#  echo $f
#  zgrep -e "\(TcpTransport::connect\|BaseTransport::BaseTransport\)" $f > /tmp/nacho_log 
#  ./parse-connection.pl /tmp/nacho_log   >> /tmp/connection_log
#done
#./genplot-connection.pl /tmp/connection_log conf/boot data/conn.dot
#neato -Tpdf data/conn.dot -o result/conn_$label.pdf

# add an entry to the web page
index_page="${webdir}/index.html"
cat <<EOF >> ${index_page}
<table>
<tr> <td>${last_log_set}</td> </tr>
<tr> <td> <a href="${last_log_dir}/index.html">${last_log_dir}</a> </td> </tr>

</table>

EOF

log_page="${webdir}/${last_log_dir}/index.html"
cat <<EOF > ${log_page}
<html>
<head>
  <title>${last_log_set} - ${last_log_dir}</title>
</head>

<body>
<h1>${last_log_set}</h1>
<h2>${last_log_dir}</h2>

<table border=1>
<tr> <td> <a href="boot">boot</a> </td> </tr>
<tr> <td> <a href="console.log">console.log</a> </td> </tr>
<tr> <td> <a href="params-run-client.conf">params-run-client.conf</a> </td> </tr>
<tr> <td> <a href="params-run-server.conf">params-run-server.conf</a> </td> </tr>

<tr> <td> <a href="column-throughput.ts">column-throughput.ts</a> </td> </tr>
<tr> <td> <a href="stat_throughput.ts">stat_throughput.ts</a> </td> </tr>
<tr> <td> <a href="avg-throughput.ts">avg-throughput.ts</a> </td> </tr>
<tr> <td> <a href="conn.dot">conn.dot</a> </td> </tr>

<tr> <td> client logs, server logs... </td> </tr>
<tr> <td> <a href="stat-throughput.png">
  <p>Throughput histogram</p>
  <img src="stat-throughput.png"></a> </td> </tr>
<tr> <td> <a href="throughput.png">
  <p>Throughput time series</p>
  <img src="throughput.png"></img></a> </td> </tr>
<tr> <td> <a href="${conn_graph}">
  <p>Network connection graph</p>
  <img src="${conn_graph}" width=800></img> </a> </td> </tr>

</table>
</body>
</html>

EOF

chmod -R 755 ${webdir}/${last_log_data}
