#!/bin/bash

application="throughput"
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

webdir="/homes/chuangw/.www/benchmark/$application"

# find the latest log set
echo "logdir=${logdir}"

echo "copy stat_throughput.ts"
cp log/data/stat_throughput.ts ${webdir}/${log_set_dir}/
echo "copy stat-throughput.png"
cp log/result/stat-throughput.png ${webdir}/${log_set_dir}/
echo "copy avg-throughput.ts"
cp log/data/avg-throughput.ts ${webdir}/${log_set_dir}/
echo "copy avg-throughput.png"
cp log/result/avg-throughput.png ${webdir}/${log_set_dir}/

# add an entry to the web page
index_page="${webdir}/index.html"
cat <<EOF >> ${index_page}
<table border=1>
<tr> <td>${log_set_dir}</td> </tr>
<tr> <td> <a href="${log_set_dir}/avg-throughput.ts">avg-throughput.ts</a> </td> </tr>
<tr> <td> <a href="${log_set_dir}/avg-throughput.png">
  <p>Average Throughput </p>
  <img src="${log_set_dir}/avg-throughput.png"></a> </td> </tr>
<tr> <td> <a href="${log_set_dir}/stat_throughput.ts">stat_throughput.ts</a> </td> </tr>
<tr> <td> <a href="${log_set_dir}/stat-throughput.png">
  <p>Throughput histogram</p>
  <img src="${log_set_dir}/stat-throughput.png"></a> </td> </tr>

EOF

for d in ${logdir}/${log_set_dir}/*; do
  dn=`echo $d | awk -F/ '{print $NF}'`
  echo $dn
  cat <<EOF >> ${index_page}
<tr> <td> <a href="${log_set_dir}/${dn}/index.html">${dn}</a> </td> </tr>
EOF

done

cat <<EOF >> ${index_page}
</table>
EOF

chmod -R 755 ${webdir}/index.html
chmod -R 755 ${webdir}/${log_set_dir}