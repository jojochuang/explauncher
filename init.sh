source ../common.sh
function init() {
  if [ $config_only -eq 0 ]; then
    # create log directories on all nodes
    ${psshdir}/pssh -h $host_orig_file -t 30 mkdir -p $scratchdir

    # sync executable
    executable_file_name="${application}_${flavor}"
    if [[ $ec2 -eq 1 ]]; then
      echo "rsync scripts ..."
      cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ../*.sh {}:~/benchmark
      cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz *.sh *.py {}:~/benchmark/$application
      echo "rsync executable $executable_file_name ..."
      cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz $executable_file_name {}:~/benchmark/$application
    fi
    echo "remove statics data"
    f1="log/data/utilization.ts"
    f2="log/data/get-latency.ts"
    f3="log/data/put-latency.ts"
    f4="log/data/avg-throughput.ts"
    f5="log/data/avg-latency"

    if [ ! -d data ]; then
      mkdir -p data
    fi
    if [ ! -d result ]; then
      mkdir -p result
    fi

    for f in $f1 $f2 $f3 $f4; do
      if [ -f $f ]; then
        rm -f $f
      fi
    done
  fi
}

init

