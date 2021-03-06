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
echo "\$application = $application, \$logdir = $logdir, \$log_set_dir = $log_set_dir, \$webdir = $webdir"

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
cp data/column-throughput.ts ${webdir}/${log_set_dir}/$last_log_dir
echo "copy conn.dot"
cp data/conn.dot ${webdir}/${log_set_dir}/$last_log_dir

# find the latest connection graph
conn_graph=`ls -tr result/conn*.png | tail -n1 | awk -F/ '{print $NF}' `
cp result/${conn_graph} ${webdir}/${log_set_dir}/$last_log_dir
cp result/throughput.png ${webdir}/${log_set_dir}/$last_log_dir
cp result/client-throughput.png ${webdir}/${log_set_dir}/$last_log_dir
cp result/net-write.png ${webdir}/${log_set_dir}/$last_log_dir
cp result/net-read.png ${webdir}/${log_set_dir}/$last_log_dir
cp result/utilization-timeseries.png ${webdir}/${log_set_dir}/$last_log_dir
if [ -f result/get-latency-timeseries.png ]; then 
    cp result/get-latency-timeseries.png ${webdir}/${log_set_dir}/$last_log_dir
    cp result/combined-get-latency.png ${webdir}/${log_set_dir}/$last_log_dir
fi
if [ -f result/put-latency-timeseries.png ]; then 
    cp result/put-latency-timeseries.png ${webdir}/${log_set_dir}/$last_log_dir
    cp result/combined-put-latency.png ${webdir}/${log_set_dir}/$last_log_dir
fi
if [ -f result/get-latency.png ]; then 
  cp result/get-latency.png ${webdir}/${log_set_dir}/$last_log_dir
fi
if [ -f result/put-latency.png ]; then 
  cp result/put-latency.png ${webdir}/${log_set_dir}/$last_log_dir
fi

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
<tr> 
EOF

if [ -f result/get-latency.png ]; then 
cat <<EOF >> ${log_page}
<td> <a href="get-latency.png">
  <p>Round-trip latency of Get request</p>
  <img src="get-latency.png"></img></a> </td>
EOF
fi


if [ -f result/put-latency.png ]; then 
cat <<EOF >> ${log_page}
<td> <a href="put-latency.png">
  <p>Round-trip latency of Put request</p>
  <img src="put-latency.png"></img></a> </td>
EOF
fi


cat <<EOF >> ${log_page}
 </tr>
<tr> <td> <a href="net-write.png">
  <p>Network Write time series</p>
  <img src="net-write.png"></img></a> </td>
     <td> <a href="net-read.png">
  <p>Network Read time series</p>
  <img src="net-read.png"></img></a> </td> </tr>

<tr> <td> <a href="throughput.png">
  <p>Throughput time series</p>
  <img src="throughput.png"></img></a> </td>
     <td> <a href="client-throughput.png">
  <p>Client throughput time series</p>
  <img src="client-throughput.png"></img></a> </td> </tr>
<tr> <td colspan=2> <a href="utilization-timeseries.png">
  <p>Utilization time series</p>
  <img src="utilization-timeseries.png"></img></a> </td> </tr>

EOF
if [ -f result/get-latency-timeseries.png ]; then 
cat <<EOF >> ${log_page}
<tr>
  <td> <a href="get-latency-timeseries.png">
  <p>Timeseries of round-trip latency of Get request</p>
  <img src="get-latency-timeseries.png"></img></a> </td>
<td> <a href="combined-get-latency.png">
  <p>Timeseries of round-trip latency of Get request versus server scale </p>
  <img src="combined-get-latency.png"></img></a> </td>
</tr>
EOF
fi
if [ -f result/put-latency-timeseries.png ]; then 
cat <<EOF >> ${log_page}
<tr>
<td> <a href="put-latency-timeseries.png">
  <p>Timeseries of round-trip latency of Put request</p>
  <img src="put-latency-timeseries.png"></img></a> </td>
<td> <a href="combined-put-latency.png">
  <p>Timeseries of round-trip latency of Put request versus server scale </p>
  <img src="combined-put-latency.png"></img></a> </td>
</tr>
EOF
fi

cat <<EOF >> ${log_page}
<tr> <td colspan=2> <a href="${conn_graph}">
  <p>Network connection graph</p>
  <img src="${conn_graph}"></img> </a> </td> </tr>

</table>
</body>
</html>

EOF

chmod -R 755 ${webdir}/${log_set_dir}/${last_log_data}
