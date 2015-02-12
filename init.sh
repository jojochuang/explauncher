source ../common.sh
function cleanup() {
    echo "remove statics data"
    f1="data/avg-utilization.ts"
    f2="data/get-latency.ts"
    f3="data/put-latency.ts"
    f4="data/avg-throughput.ts"
    f5="data/avg-latency.ts"
    f6="data/all_raw_cpu.ts"
    f7="data/all_raw_latency.ts"
    for f in $f1 $f2 $f3 $f4 $f5 $f6 $f7; do
      if [ -f $f ]; then
        rm -f $f
      fi
    done
}
function init() {
  if [ $config_only -eq 0 ]; then
    # create log directories on all nodes
    ${psshdir}/pssh -h $host_orig_file -t 30 mkdir -p $scratchdir

    # sync executable
    executable_file_name="${application}_${flavor}"
    if [[ $ec2 -eq 1 ]]; then
      echo "rsync scripts ..."
      cat ${host_orig_file} | xargs --max-lines=1 -I {} rsync -vauz ../common {}:~/benchmark
      cat ${host_orig_file} | xargs --max-lines=1 -I {} rsync -vauz ../*.sh {}:~/benchmark
      cat ${host_orig_file} | xargs --max-lines=1 -I {} rsync -vauz *.sh *.py {}:~/benchmark/$application
      echo "rsync executable $executable_file_name ..."
      cat ${host_orig_file} | xargs --max-lines=1 -I {} rsync -vauz $executable_file_name {}:~/benchmark/$application
    fi

    if [ ! -d data ]; then
      mkdir -p data
    fi
    if [ ! -d result ]; then
      mkdir -p result
    fi
    cleanup

  fi
}

init

