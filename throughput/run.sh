#!/bin/bash
# This is the script that runs multiple throughput benchmarks of the nacho runtime. 
application="throughput"
source ../common.sh

mace_start_port=30000
scale=8

runtime=100 # duration of the experiment
boottime=10   # total time to boot.

tcp_nodelay=1   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.

#nruns=1      # number of replicated runs
nruns=5      # number of replicated runs

#flavor="nacho"
flavor="context"

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
  echo "MACE_START_PORT = ${mace_start_port}" >> ${conf_file}

  echo "run_time = ${runtime}" >> ${conf_file}
  echo "SET_TCP_NODELAY = ${tcp_nodelay}" >> ${conf_file}

  echo "MACE_LOG_AUTO_SELECTORS = \"Accumulator GlobalStateCoordinator TcpTransport::connect BaseTransport::BaseTransport DefaultMappingPolicy\"" >> ${conf_file}
  echo "MACE_LOG_ACCUMULATOR = 1000" >> ${conf_file}

  echo "WORKER_JOIN_WAIT_TIME = 60" >>  ${conf_file}
  echo "CLIENT_WAIT_TIME = 30" >> ${conf_file}

  echo "CONTEXT_ASSIGNMENT_POLICY = ${context_policy}" >> ${conf_file}

  echo "SERVER_CONFFILE = ${conf_dir}/params-run-client.conf" >> $conf_file
  echo "CLIENT_CONFFILE = ${conf_dir}/params-run-server.conf" >> $conf_file
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
  t_machines=$(($t_server_machines + $t_client_machines + 1))

  #for t_ncontexts in 24; do  # Number of total buildings across all the servers
  t_scale=$(($t_server_machines+1))
  t_ncontexts=$(($t_scale*6 ))

  initial_server_size=$(($t_server_machines+1))

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

  if [[ $ec2 -eq 0 ]]; then
    # do not use monitor
    echo -e "\e[00;31m\$ ./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}\e[00m"
    ./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}

  else
    # do not use monitor
    #./master.py -a throughput -f context -p conf/params-run-server.conf -i n-c-p1-e-l
    echo -e "\e[00;31m\$ ./master.py -a ${application} -f ${flavor} -p ${conf_file} -i n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}\e[00m"
    ./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_ncontexts}-p${t_primes}
  fi
  sleep 10

}

function aggregate_output () {
  log_set_dir=$1
  t_clients=$2
  t_primes=$3
  # create a new directory for the set of logs
  #log_set_dir=`date --iso-8601="seconds"`
  mkdir ${logdir}/${log_set_dir}
  # move the log directories into the new dir
  mv ${logdir}/${application}-* ${logdir}/${log_set_dir}/
  # parse the logs in each of the log directory, and aggregate the throughput
  # measure throughput from 10% to 90% (assuming the throughput is stable in the period)
  # compute average and standard deviation
  # append to the output file
  cwd=`pwd`
  cd log
  ./run-throughput.sh ${logdir}/${log_set_dir} $flavor-$t_clients-$t_primes
  cd $cwd
}

function init() {
  # create directories on all nodes
  pssh -h conf/hosts -t 30 mkdir -p $scratchdir
  #if [[ $ec2 -eq 1 ]]; then
  #else

  #fi
}

init

for t_server_machines in 1; do
  for t_client_machines in  1; do
    for t_clients in 2; do
      for t_primes in 1; do  # Additional computation payload at the server.
        log_set_dir=`date --iso-8601="seconds"`
        for (( run=1; run <= $nruns; run++ )); do
          mace_start_port=$((mace_start_port+500))
          runexp $t_server_machines $t_client_machines $t_clients $t_primes

          # generate plots
          cwd=`pwd`
          cd log
          ./plot_connection.sh ${t_server_machines}-${t_clients}-$run
          ./run-timeseries.sh
          ./run-avg.sh
          cd $cwd
          # publish plots and parameters and logs to web page
          #if [[ $ec2 -eq 0 ]]; then
            ./publish.sh $log_set_dir
          #fi
        done # end of nruns

        #TODO: compute avg and stddev, and plot error bar.
        # Find the last $nruns log, aggregate the compute/plot error bar

        # what to plot? the average throughput w/ error
        aggregate_output $log_set_dir $t_clients $t_primes 
        #if [[ $ec2 -eq 0 ]]; then
          ./publish_webindex.sh $log_set_dir
        #fi
        ./plot_service.sh
      done # end of total_events
    done
  done
done

