#!/bin/bash

source conf/conf.sh
source ../common.sh

# copy to cs website the logs, parameters:
#   boot, hosts-run, console.log, client log, server log,  parameter file, client/server console log
#   log/data/avg-throughput.ts, log/data/stat_throughput.ts
#   log/data/column-throughput.ts
#   log/result/throughput.pdf, log/result/stat-throughput.pdf/png
#   log/result/conn*.pdf

log_set_dir=$1

if [[ $# -lt 1 ]]; then
  echo "need the log set dir as the parameter"
  exit
fi

# find the latest log set
echo "logdir=${logdir}"

echo "log_set_dir=${log_set_dir}"
last_log_dir=`ls -tr ${logdir} | tail -n1`

if [[ $ec2 -eq 0 ]]; then
  webdir="/homes/chuangw/.www/benchmark/$application"
  #url_prefix="http://www.cs.purdue.edu/homes/chuangw/benchmark/$application/${log_set_dir}/${last_log_dir}/"
else
  webdir="/var/www/benchmark/$application"
  #url_prefix="http://ec2-54-81-182-184.compute-1.amazonaws.com/benchmark/$application/${log_set_dir}/${last_log_dir}/"
fi

if [ ! -d $webdir ]; then
  mkdir $webdir
  chmod 755 $webdir
fi

if [ ! -d $webdir/$log_set_dir ]; then
  mkdir $webdir/$log_set_dir
fi


echo "copy log directory"
cp -R ${logdir}/$last_log_dir ${webdir}/${log_set_dir}/${last_log_dir}
echo "copy column-throughput.ts"
cp log/data/column-throughput.ts ${webdir}/${log_set_dir}/$last_log_dir
echo "copy conn.dot"
cp log/data/conn.dot ${webdir}/${log_set_dir}/$last_log_dir

# find the latest connection graph
conn_graph=`ls -tr log/result/conn*.png | tail -n1 | awk -F/ '{print $NF}' `
cp log/result/${conn_graph} ${webdir}/${log_set_dir}/$last_log_dir
cp log/result/throughput.png ${webdir}/${log_set_dir}/$last_log_dir
cp log/result/net-write.png ${webdir}/${log_set_dir}/$last_log_dir
cp log/result/net-read.png ${webdir}/${log_set_dir}/$last_log_dir
cp log/result/get-latency.png ${webdir}/${log_set_dir}/$last_log_dir
cp log/result/put-latency.png ${webdir}/${log_set_dir}/$last_log_dir

# add an entry to the web page

log_page="${webdir}/${log_set_dir}/${last_log_dir}/index.html"
cat <<EOF > ${log_page}
<html>
<head>
  <title>${log_set_dir} - ${last_log_dir}</title>
</head>

<body>
<h1>Log set: ${log_set_dir}</h1>
<h2>Log identifier: ${last_log_dir}</h2>

<table border=1>
<tr> <td> <a href="boot">boot</a> </td> </tr>
<tr> <td> <a href="console.log">console.log</a> </td> </tr>
<tr> <td> <a href="params-run-client.conf">params-run-client.conf</a> </td> </tr>
<tr> <td> <a href="params-run-server.conf">params-run-server.conf</a> </td> </tr>

<tr> <td> <a href="column-throughput.ts">column-throughput.ts</a> </td> </tr>
<tr> <td> <a href="conn.dot">conn.dot</a> </td> </tr>

<tr> <td> client logs, server logs... </td> </tr>
<tr> <td> <a href="get-latency.png">
  <p>Round-trip latency of Get request</p>
  <img src="get-latency.png"></img></a> </td> </tr>
<tr> <td> <a href="put-latency.png">
  <p>Round-trip latency of Put request</p>
  <img src="put-latency.png"></img></a> </td> </tr>
<tr> <td> <a href="net-write.png">
  <p>Network Write time series</p>
  <img src="net-write.png"></img></a> </td> </tr>
<tr> <td> <a href="net-read.png">
  <p>Network Read time series</p>
  <img src="net-read.png"></img></a> </td> </tr>
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

chmod -R 755 ${webdir}/${log_set_dir}/${last_log_data}
