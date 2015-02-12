#!/bin/bash
# This is the script that runs multiple throughput benchmarks of the nacho runtime. 
source conf/conf.sh
source ../common.sh
source ../init.sh

mace_start_port=30000

runtime=200 # duration of the experiment
boottime=50   # total time to boot.
worker_join_wait_time=40
client_wait_time=20

tcp_nodelay=1   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.

#nruns=1      # number of replicated runs
nruns=5      # number of replicated runs

#context_policy="NO_SHIFT"
#context_policy="SHIFT_BY_ONE"
context_policy="RANDOM"

# migration pattern parameters
t_days=6
day_period=40000000
day_join=0.2
day_leave=0.5
day_error=0.2

conf_client_file="conf/params-run-client.conf"
conf_file="conf/params-run-server.conf"
host_nohead_file="conf/hosts-run-nohead"

if [ $# -eq 0 ]; then
    id="default"
else
    id=$1
fi

# generate parameters for the benchmark. Parameters do not change in each of the benchmarks
function GenerateBenchmarkParameter (){
  conf_file=$1

  echo "application = ${application}" >> ${conf_file}
  echo "TOTAL_BOOT_TIME = ${boottime}" >> ${conf_file}

  echo "HOSTNOHEADFILE = ${conf_dir}/hosts-run-nohead" >> $conf_file
  echo "BINARY = ${application}_${flavor}" >> ${conf_file}
  echo "flavor = ${flavor}" >> ${conf_file}
  echo "MACE_START_PORT = ${mace_start_port}" >> ${conf_file}

  echo "run_time = ${runtime}" >> ${conf_file}
  echo "SET_TCP_NODELAY = ${tcp_nodelay}" >> ${conf_file}

  echo "MACE_LOG_AUTO_SELECTORS = \"HeadEventTP::constructor ContextService::createContextObjectWrapper ContextMapping::getParentContextID Accumulator GlobalStateCoordinator TcpTransport::connect BaseTransport::BaseTransport DefaultMappingPolicy ServiceComposition\"" >> ${conf_file}
  echo "MACE_LOG_ACCUMULATOR = 1000" >> ${conf_file}

  echo "WORKER_JOIN_WAIT_TIME = ${worker_join_wait_time}" >>  ${conf_file}
  echo "CLIENT_WAIT_TIME = ${client_wait_time}" >> ${conf_file}

  echo "CONTEXT_ASSIGNMENT_POLICY = ${context_policy}" >> ${conf_file}

  echo "CLIENT_CONFFILE = $conf_client_file" >> $conf_file
  echo "SERVER_CONFFILE = $conf_file" >> $conf_file

  echo "GRAPHVIZ_FILE = /tmp/gv.dot" >> $conf_file
  if [[ $ec2 -eq 1 ]]; then
    echo "EC2 = 1" >> ${conf_file}
    echo "SYNC_CONF_FILES = 1" >> ${conf_file}
  else
    echo "EC2 = 0" >> ${conf_file}
    echo "SYNC_CONF_FILES = 0" >> ${conf_file}
  fi
}

function runexp (){
  t_server_machines=$1
  t_client_machines=$2
  t_clients=$3
  t_primes=$4

  # For each server machine, you will run only one server process.
  t_servers=$t_server_machines

  #t_clients_per_machine=$(($t_clients/$t_client_machines))

  # Get actual number of machines you will be using
  t_machines=$(($t_server_machines + $t_client_machines))

  #for t_ncontexts in 24; do  # Number of total buildings across all the servers
  #t_scale=$(($t_server_machines+1))
  t_scale=$(($t_server_machines))
  t_ncontexts=$(($t_scale*6 ))

  #initial_server_size=$(($t_server_machines+1))
  initial_server_size=$(($t_server_machines))

  cp ${conf_orig_file} ${conf_file}

  GenerateCommonParameter ${conf_file}
  GenerateBenchmarkParameter ${conf_file}

  # Generate parameters common to server and clients in this benchmark
  echo "ServiceConfig.Throughput.NSENDERS = ${initial_server_size}" >>  ${conf_file}
  echo "ServiceConfig.Throughput.NUM_PRIMES = ${t_primes}" >> ${conf_file}
  echo "ServiceConfig.Throughput.NCONTEXTS = ${t_ncontexts}" >>  ${conf_file}

  echo "num_machines = ${t_machines}" >> ${conf_file}
  echo "num_server_machines = ${t_server_machines}" >> ${conf_file}
  echo "num_client_machines = ${t_client_machines}" >> ${conf_file}
  echo "num_servers = ${t_servers}" >> ${conf_file}
  echo "num_clients = ${t_clients}" >> ${conf_file}
  echo "num_contexts = ${t_ncontexts}" >> ${conf_file}
  echo "day_period = ${day_period}" >> ${conf_file}
  echo "day_join = ${day_join}" >> ${conf_file}
  echo "day_leave = ${day_leave}" >> ${conf_file}
  echo "day_error = ${day_error}" >> ${conf_file}
  echo "num_days = ${t_days}" >> ${conf_file}

  # copy the param file for clients
  cp ${conf_file} ${conf_client_file}

  echo -e "\n# Specific parameters for client" >> ${conf_client_file}

  echo "ServiceConfig.Throughput.message_length = 1" >> ${conf_client_file}
  echo "lib.MApplication.initial_size = 1" >> ${conf_client_file}
  echo "ServiceConfig.Throughput.role = 1" >>  ${conf_client_file}
  echo "MACE_LOG_AUTO_ALL = 0" >> ${conf_client_file}

  # copy the param file for the server
  echo -e "\n# Specific parameters for server" >> ${conf_file}

  echo "lib.MApplication.services = Throughput" >> ${conf_file}
  echo "lib.MApplication.initial_size = ${initial_server_size}" >> ${conf_file}
  echo "ServiceConfig.Throughput.role = 2" >>  ${conf_file}
  echo "MACE_LOG_AUTO_ALL = 0" >> ${conf_file}

  # print out bootfile & param for servers
  echo -e "\e[00;31m\$ ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}\e[00m"
  ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}

  if [[ $? -ne 0 ]]; then
    echo "Error occurred while processing ./configure-${application}.py. Terminated."
    exit 1;
  fi

  if [ $config_only -eq 0 ]; then
    if [[ $ec2 -eq 0 ]]; then
      # do not use monitor
      echo -e "\e[00;31m\$ $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}\e[00m"
      $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}

    else
      # do not use monitor
      echo -e "\e[00;31m\$ $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -i n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}\e[00m"
      $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}
    fi
    sleep 10
  fi

}

function aggregate_output () {
  log_set_dir=$1
  t_servers=$2
  t_clients=$3
  t_primes=$4
  # create a new directory for the set of logs
  mkdir ${logdir}/${log_set_dir}
  # move the log directories into the new dir
  mv ${logdir}/${application}-* ${logdir}/${log_set_dir}/
  # parse the logs in each of the log directory, and aggregate the throughput
  # measure throughput from 10% to 90% (assuming the throughput is stable in the period)
  # compute average and standard deviation
  # append to the output file
  label="$flavor-$t_servers-$t_clients-$t_primes"
  $plotter/run-throughput.sh ${logdir}/${log_set_dir} $label
  $plotter/run-avg.sh
  #$plotter/avg-latency.sh
  #$plotter/stat-latency.sh $label
  $plotter/avg-utilization.sh 
  $plotter/stat-utilization.sh $label
  $plotter/plot_service.sh
}

#for t_server_machines in 1; do
for t_server_machines in 1 2 4; do
  t_client_machines=$t_server_machines
  t_clients=$(( $t_client_machines * 4 ))
  for t_primes in 1 10 20 50 ; do  # Additional computation payload at the server.
  #for t_primes in 1; do  # Additional computation payload at the server.
    log_set_dir=`date --iso-8601="seconds"`
    cleanup # function to remove files that aggregates data from multiple runs of the same setting.
    for (( run=1; run <= $nruns; run++ )); do
      mace_start_port=$((mace_start_port+500))
      runexp $t_server_machines $t_client_machines $t_clients $t_primes

      if [ $config_only -eq 0 ]; then
        # generate plots
        $plotter/plot_connection.sh ${t_server_machines}-${t_clients}-$run
        $plotter/run-timeseries.sh
        $plotter/run-net.sh
        $plotter/parse-utilization.sh
        # publish plots and parameters and logs to web page
        $common/publish.sh $log_set_dir
      fi
    done # end of nruns

    # what to plot? the average throughput w/ error
    if [ $config_only -eq 0 ]; then
      aggregate_output $log_set_dir $t_server_machines $t_clients $t_primes 

      $common/publish_webindex.sh $log_set_dir
    fi
  done # end of total_events
done

