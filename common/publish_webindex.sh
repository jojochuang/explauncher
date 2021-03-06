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

echo "log_set_dir=${log_set_dir}"

# find the latest log set
echo "logdir=${logdir}"
#throughput
echo "copy stat_throughput.ts"
cp data/stat_throughput.ts ${webdir}/${log_set_dir}/
echo "copy stat-throughput.png"
cp result/stat-throughput.png ${webdir}/${log_set_dir}/
echo "copy avg-throughput.ts"
cp data/avg-throughput.ts ${webdir}/${log_set_dir}/
echo "copy avg-throughput.png"
cp result/avg-throughput.png ${webdir}/${log_set_dir}/

#latency
if [ -f "result/avg-latency.png" ]; then
    echo "copy avg-latency.png"
    cp result/avg-latency.png ${webdir}/${log_set_dir}/
    echo "copy avg-latency.ts"
    cp data/avg-latency.ts ${webdir}/${log_set_dir}/
fi
if [ -f "result/avg-client.png" ]; then
    echo "copy avg-client.png"
    cp result/avg-client.png ${webdir}/${log_set_dir}/
    echo "copy avg-client.ts"
    cp data/avg-client.ts ${webdir}/${log_set_dir}/
fi

if [ -f "result/stat-latency.png" ]; then
    echo "copy stat-latency.png"
    cp result/stat-latency.png ${webdir}/${log_set_dir}/
    echo "copy stat-latency.ts"
    cp data/stat-latency.ts ${webdir}/${log_set_dir}/
fi

if [ -f "result/stat-client.png" ]; then
    echo "copy stat-client.png"
    cp result/stat-client.png ${webdir}/${log_set_dir}/
    echo "copy stat-client.ts"
    cp data/stat-client.ts ${webdir}/${log_set_dir}/
fi

echo "copy service_struct.png"
cp result/service_struct.png ${webdir}/${log_set_dir}/

#utilization
echo "copy stat-utilization.ts"
cp data/stat-utilization.ts ${webdir}/${log_set_dir}/

echo "copy stat-utilization.png"
cp result/stat-utilization.png ${webdir}/${log_set_dir}/

echo "copy avg-utilization.ts"
cp data/avg-utilization.ts ${webdir}/${log_set_dir}/

echo "copy avg-utilization.png"
cp result/avg-utilization.png ${webdir}/${log_set_dir}/

# add an entry to the web page
index_page="${webdir}/index.html"
cat <<EOF >> ${index_page}
<table border=1>
<tr> <td>${log_set_dir}</td> </tr>
<tr> <td> <p>Service structure </p><a href="${url_prefix}${log_set_dir}/service_struct.png">
  <img src="${url_prefix}${log_set_dir}/service_struct.png"></a> </td> </tr>

<tr> <td> <a href="${url_prefix}${log_set_dir}/avg-throughput.ts">avg-throughput.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/avg-utilization.ts">avg-utilization.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/avg-latency.ts">avg-latency.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/avg-client.ts">avg-client.ts</a> </td> </tr>

<tr> <td> <a href="${url_prefix}${log_set_dir}/avg-throughput.png">
  <p>Average Throughput </p>
  <img src="${url_prefix}${log_set_dir}/avg-throughput.png" width=360></a> </td> 

     <td> <a href="${url_prefix}${log_set_dir}/avg-utilization.png">
  <p>Average Utilization</p>
  <img src="${url_prefix}${log_set_dir}/avg-utilization.png" width=360></a> </td>

EOF
if [ -f "result/avg-latency.png" ]; then
cat <<EOF >> ${index_page}
     <td> <a href="${url_prefix}${log_set_dir}/avg-latency.png">
  <p>Average Latency </p>
  <img src="${url_prefix}${log_set_dir}/avg-latency.png" width=360></a> </td>
EOF
fi

if [ -f "result/avg-client.png" ]; then
cat <<EOF >> ${index_page}
     <td> <a href="${url_prefix}${log_set_dir}/avg-client.png">
  <p>Client Average Throughput </p>
  <img src="${url_prefix}${log_set_dir}/avg-client.png" width=360></a> </td>
EOF
fi

cat <<EOF >> ${index_page}
 </tr>
<tr> <td> <a href="${url_prefix}${log_set_dir}/stat_throughput.ts">stat_throughput.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/stat-utilization.ts">stat-utilization.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/stat-latency.ts">stat-latency.ts</a> </td>
     <td> <a href="${url_prefix}${log_set_dir}/stat-client.ts">stat-client.ts</a> </td> </tr>

<tr> <td> <a href="${url_prefix}${log_set_dir}/stat-throughput.png">
  <p>Throughput histogram</p>
  <img src="${url_prefix}${log_set_dir}/stat-throughput.png" width=360></a> </td>

     <td> <a href="${url_prefix}${log_set_dir}/stat-utilization.png">
  <p>Utilization statistics</p>
  <img src="${url_prefix}${log_set_dir}/stat-utilization.png" width=360></a> </td>
EOF

if [ -f "result/stat-latency.png" ]; then
cat <<EOF >> ${index_page}
  
     <td> <a href="${url_prefix}${log_set_dir}/stat-latency.png">
  <p>Latency statistics</p>
  <img src="${url_prefix}${log_set_dir}/stat-latency.png" width=360></a> </td>
EOF
fi

if [ -f "result/stat-client.png" ]; then
cat <<EOF >> ${index_page}
  
     <td> <a href="${url_prefix}${log_set_dir}/stat-client.png">
  <p>Client Throughput Statistics</p>
  <img src="${url_prefix}${log_set_dir}/stat-client.png" width=360></a> </td>
EOF
fi
cat <<EOF >> ${index_page}
     </tr>
EOF

for d in ${logdir}/${log_set_dir}/*; do
  dn=`echo $d | awk -F/ '{print $NF}'`
  echo $dn
  cat <<EOF >> ${index_page}
<tr> <td colspan=4> <a href="${url_prefix}${log_set_dir}/${dn}/index.html">${dn}</a> </td> </tr>
EOF

done

cat <<EOF >> ${index_page}
</table>
EOF

chmod -R 755 ${webdir}/index.html
chmod -R 755 ${webdir}/${log_set_dir}
