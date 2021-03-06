#!/bin/bash
#set -e
# This is the script that runs multiple throughput benchmarks of the nacho runtime. 
source conf/conf.sh
source ../common.sh
source ../init.sh

mace_start_port=30000
# number of server logical nodes does not change
n_server_logicalnode=1
server_scale=8
t_server_machines=$(( $n_server_logicalnode * $server_scale ))
t_client_machines=4
#n_client_logicalnode=2
t_ncontexts=$(( 4* $server_scale ))
t_ngroups=$t_ncontexts # number of partitions at server

# to save cost, the number of client physical nodes are less than that of the client logical nodes
# so client logical nodes are equally distributed to the physical nodes.

logical_nodes_per_physical_nodes=7

runtime=200 # duration of the experiment
boottime=40   # total time to boot.
server_join_wait_time=0
client_wait_time=0
port_shift=10  # spacing of ports between different nodes
memory_rounds=1000 # frequency of memory usage log printing
t_payload=1000
#t_mean=16 # utilization around 40%, moderate load

tcp_nodelay=1   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.

#nruns=1      # number of replicated runs
nruns=1      # number of replicated runs

#context_policy="NO_SHIFT"
#context_policy="SHIFT_BY_ONE"
context_policy="RANDOM"
#context_policy="HEAD_ONLY"

# migration pattern parameters
t_days=15
day_period=200000000
day_join=0.5
day_leave=0.5
day_error=0.2

conf_client_file="conf/params-run-client.conf"
conf_file="conf/params-run-server.conf"
host_nohead_file="conf/hosts-run-nohead"
server_scale_file="data/scale_server.ts"

if [ $# -eq 0 ]; then
    id="default"
else
    id=$1
fi

no_config=0 # whether to run configure.py for new configs
# generate parameters for the benchmark. Parameters do not change in each of the benchmarks
function GenerateBenchmarkParameter (){
  conf_file=$1

  echo "server_scale_file = ${server_scale_file}" >> ${conf_file}

  echo "application = ${application}" >> ${conf_file}
  echo "port_shift = ${port_shift}" >> ${conf_file}
  echo "SERVER_LOGICAL_NODES = ${n_server_logicalnode}" >> ${conf_file}
  echo "TOTAL_BOOT_TIME = ${boottime}" >> ${conf_file}

  echo "HOSTNOHEADFILE = ${conf_dir}/hosts-run-nohead" >> $conf_file
  echo "BINARY = ${application}_${flavor}" >> ${conf_file}
  echo "flavor = ${flavor}" >> ${conf_file}
  echo "MACE_START_PORT = ${mace_start_port}" >> ${conf_file}

  echo "run_time = ${runtime}" >> ${conf_file}
  echo "SET_TCP_NODELAY = ${tcp_nodelay}" >> ${conf_file}

  #echo "MACE_LOG_AUTO_SELECTORS = \"ContextBaseClass::updateVisitedEvents ContextService::requestContextMigrationCommon ContextService::handle__event_MigrateContext Accumulator GlobalStateCoordinator TcpTransport::connect BaseTransport::BaseTransport DefaultMappingPolicy ServiceComposition HeadEventTP::constructor BS_KeyValueClient\"" >> ${conf_file}
  echo "MACE_LOG_AUTO_SELECTORS = \"ContextService::requestContextMigrationCommon ContextService::handle__event_MigrateContext Accumulator GlobalStateCoordinator TcpTransport::connect BaseTransport::BaseTransport DefaultMappingPolicy ServiceComposition HeadEventTP::constructor BS_KeyValueClient\"" >> ${conf_file}
  echo "MACE_LOG_ACCUMULATOR = 1000" >> ${conf_file}

  echo "WORKER_JOIN_WAIT_TIME = ${server_join_wait_time}" >>  ${conf_file}
  echo "CLIENT_WAIT_TIME = ${client_wait_time}" >> ${conf_file}

  echo "CONTEXT_ASSIGNMENT_POLICY = ${context_policy}" >> ${conf_file}

  echo "SERVER_CONFFILE = $conf_file" >> $conf_file
  echo "CLIENT_CONFFILE = $conf_client_file" >> $conf_file

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
  t_mean=$5

  # For each server machine, run only one server process.
  # minus the bootstrapper node
  #t_servers=$(( $t_server_machines - $n_server_logicalnode ))
  t_servers=$t_server_machines

  #t_clients_per_machine=$(($t_clients/$t_client_machines))

  # Get actual number of machines you will be using
  #t_machines=$(($t_server_machines + $t_client_machines + 1))
  # TODO: include the head node
  t_machines=$(($t_server_machines + $t_client_machines ))

  #initial_server_size=$(($t_server_machines+1))
  initial_server_size=$(($t_server_machines))

  if [ $no_config -eq 0 ]; then
    cp ${conf_orig_file} ${conf_file}

    GenerateCommonParameter ${conf_file}
    GenerateBenchmarkParameter ${conf_file}

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

    echo "role = client" >>  ${conf_client_file}
    echo "lib.MApplication.initial_size = 1" >> ${conf_client_file}
    echo "MACE_LOG_AUTO_ALL = 0" >> ${conf_client_file}
    echo "ServiceConfig.KeyValueClient.PAYLOAD = ${t_payload}" >>  ${conf_client_file}
    echo "ServiceConfig.KeyValueClient.PER_TIMER_ROUND = 1" >>  ${conf_client_file}
    echo "ServiceConfig.KeyValueClient.AVG_ROUNDS = 1" >>  ${conf_client_file}

    put_mean=$(( $t_mean * 1000 ))
    get_mean=$(( $t_mean * 1000 ))
    echo "ServiceConfig.KeyValueClient.PUTMEAN = $put_mean" >>  ${conf_client_file}
    echo "ServiceConfig.KeyValueClient.GETMEAN = $get_mean" >>  ${conf_client_file}
    echo "ServiceConfig.KeyValueClient.PUT_STOP_AT = 1" >>  ${conf_client_file}

    # copy the param file for the server
    echo -e "\n# Specific parameters for server" >> ${conf_file}

    echo "role = server" >>  ${conf_file}
    echo "lib.MApplication.services = KeyValueServer" >> ${conf_file}
    echo "lib.MApplication.initial_size = ${server_scale}" >> ${conf_file}
    echo "MACE_LOG_AUTO_ALL = 0" >> ${conf_file}
    echo "ServiceConfig.KeyValueServer.NUM_GROUPS = ${t_ngroups}" >>  ${conf_file}
    echo "ServiceConfig.KeyValueServer.MEMORY_ROUNDS = ${memory_rounds}" >>  ${conf_file}

    # print out bootfile & param for servers
    echo -e "\e[00;31m\$ ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}\e[00m"
    ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}
  fi

  if [[ $? -ne 0 ]]; then
    echo "Error occurred while processing ./configure-${application}.py. Terminated."
    exit 1;
  fi

  if [ $config_only -eq 0 ]; then
    if [[ $ec2 -eq 0 ]]; then
      # do not use monitor
      echo -e "\e[00;31m\$ $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ngroups}-p${t_primes}\e[00m"
      $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ngroups}-p${t_primes}

    else
      # do not use monitor
      #$common/master.py -a throughput -f context -p conf/params-run-server.conf -i n-c-p1-e-l
      echo -e "\e[00;31m\$ $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -i n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}\e[00m"
      $common/master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ngroups}-p${t_primes}
    fi
    sleep 10
  fi

}

function aggregate_output () {
  log_set_dir=$1
  t_clients=$2
  t_primes=$3
  t_mean=$4
  # create a new directory for the set of logs
  mkdir ${logdir}/${log_set_dir}
  # move the log directories into the new dir
  mv ${logdir}/${application}-* ${logdir}/${log_set_dir}/
  # parse the logs in each of the log directory, and aggregate the throughput
  # measure throughput from 10% to 90% (assuming the throughput is stable in the period)
  # compute average and standard deviation
  # append to the output file
  label="$flavor-$t_clients-$t_primes-$t_mean"
  $plotter/run-throughput.sh ${logdir}/${log_set_dir} $label
  $plotter/run-avg.sh
  $plotter/avg-latency.sh
  $plotter/stat-latency.sh $label
  $plotter/avg-utilization.sh 
  $plotter/stat-utilization.sh $label
  $plotter/plot_service.sh
}

function init() {
  if [ $config_only -eq 0 ]; then
    # create log directories on all nodes
    ${psshdir}/pssh -h $host_orig_file -t 30 mkdir -p $scratchdir
  fi
}

init

n_machines=`wc ${host_orig_file} | awk '{print $1}' `
  #for t_client_machines in  4; do
    n_client_logicalnode=$(( $t_client_machines * $logical_nodes_per_physical_nodes ))

    used_machines=$(( $t_client_machines +  $t_server_machines ))

    # make sure client physical nodes + server physical nodes <= all physical nodes
    if [ $used_machines -gt $n_machines ]; then
      echo "use machines: ${used_machines} > machine list: ${n_machines} "
      exit 1
    fi
    #for t_mean in 4; do
    #for t_mean in 2 8 32 128; do
    #for t_mean in 1 2 4 8 16 32; do
    #for t_mean in 1 4 16; do
    #for t_mean in 4 16; do
    #for t_mean in 4; do
    for t_mean in 8; do
    #for t_mean in 2; do
    #for t_mean in 32 64; do
    #for n_client_logicalnode in 8; do
      for t_primes in 1; do  # Additional computation payload at the server.
        cleanup # function to remove files that aggregates data from multiple runs of the same setting.
        log_set_dir=`date --iso-8601="seconds"`
        for (( run=1; run <= $nruns; run++ )); do
          mace_start_port=$((mace_start_port+500))
          runexp $t_server_machines $t_client_machines $n_client_logicalnode $t_primes $t_mean

          if [ $config_only -eq 0 ]; then
            # generate plots for each run
            $plotter/plot_connection.sh ${t_server_machines}-${n_client_logicalnode}-$run
            $plotter/run-timeseries.sh
            $plotter/run-net.sh
            $plotter/run-latency.sh
            $plotter/parse-utilization.sh
            $plotter/run-utilization.sh
            # publish plots and parameters and logs to web page
            $common/publish.sh $log_set_dir
          fi
        done # end of nruns

        if [ $config_only -eq 0 ]; then
          # plot the average throughput w/ error across all runs
          aggregate_output $log_set_dir $n_client_logicalnode $t_primes $t_mean

          $common/publish_webindex.sh $log_set_dir
        fi
      done # end of total_events
    done
  #done

