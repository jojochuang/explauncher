#!/bin/bash

# This is the script that runs multiple microbenchmarks in fullcontext.

mace_start_port=4100
boottime=10   # total time to boot.
#runtime=1000  # maximum runtime
tcp_nodelay=1   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.
#tcp_nodelay=0   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.

nruns=1      # number of replicated runs
#nruns=5      # number of replicated runs

# Some fixed values
#day_period=360000000
#day_period=100000000
prejoin_wait_time_per_client=500000
prejoin_minimum_wait_time=20000000
#day_period=100000000
#day_period=10000000
day_period=40000000

#day_period=20000000
day_join=0.2
day_leave=0.5
#day_error=0.12
day_error=0.2
t_days=6

#server_movement_period=500000
#server_movement_period=300000
server_movement_period=1000000
#server_movement_period=150000
#server_movement_period=150000
#client_request_period=500000
#client_request_period=500000
client_request_period=2000000


#samehead=1


if [ $# -eq 0 ]; then
    id="default"
else
    id=$1
fi


application="throughput"
flavor="context"

user="chuangw"
home="/homes/chuangw"                                       # Home directory
bin="/homes/chuangw/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

logdir="/u/tiberius06_s/chuangw/logs/${application}"        # Log collection directory
scratchdir="/scratch/chuangw/tmp/${application}"            # Scratch directory location

conf_dir="${bin}/conf"                    # Configuration directory
conf_orig_file="conf/params-basic.conf"   # Relative directory of conf_orig_file
conf_client_file="conf/params-run-client.conf"
conf_file="conf/params-run-server.conf"
host_orig_file="conf/hosts"
host_run_file="conf/hosts-run"
host_nohead_file="conf/hosts-run-nohead"
boot_file="conf/boot"

# For non-migration, s=8, cm=2, c=64, b=128, p=500 
# smp=300k, crp=1000k shows good graph.
#
# Yet it doesn't work with migration. So I am trying to finding
# a smaller number of dataset that works for both.
# Otherwise, I'm wrong with migration.
# Rather, I would do 


for t_server_machines in 3; do
  # For each server machine, you will run only one server process.
  t_servers=$t_server_machines
  t_servers_per_machine=$(($t_servers/$t_server_machines))

  for t_client_machines in 4; do
    #for t_clients in 500; do
    #for t_clients in 64; do
    #for t_clients in 128; do
    #for t_clients in 128; do
    for t_clients in 4; do
    #for t_clients in 8; do
      t_clients_per_machine=$(($t_clients/$t_client_machines))

      # Get actual number of machines you will be using
      t_machines=$(($t_server_machines + $t_client_machines + 1))

      prejoin_wait_time=$(($prejoin_wait_time_per_client * $t_clients))
      if [[ $prejoin_wait_time -le $prejoin_minimum_wait_time ]]; then
        prejoin_wait_time=$prejoin_minimum_wait_time
      fi
      exit_time=$(($t_days * $day_period + $day_period + $prejoin_wait_time))
      #runtime=$((exit_time/1000000+10))
      runtime=50

      #for t_buildings in 128; do  # Number of total buildings across all the servers
      for t_buildings in 8; do  # Number of total buildings across all the servers

        # Note that there will only be one room and one hallway per each building.
        t_rooms=1  # rooms per each building. DO NOT CHANGE THIS.

        #for t_primes in 500; do  # Additional computation payload at the server.
        #for t_primes in 100; do  # Additional computation payload at the server.
        for t_primes in 150; do  # Additional computation payload at the server.

          t_buildings_per_server=$(($t_buildings/$t_servers))

          #t_threads=$(($t_buildings_per_server * 2))

          #if [ $t_threads -le 2000 ]; then
          #  t_threads=2000
          #fi

          for (( run=1; run <= $nruns; run++ )); do

            cp ${conf_orig_file} ${conf_file}

            echo "application = ${application}" >> ${conf_file}

            # Default path configurations

            echo "USER = ${user}" >> ${conf_file}
            echo "HOME = ${home}" >> ${conf_file}
            echo "BIN = ${bin}" >> ${conf_file}
            echo "CONFDIR = ${conf_dir}" >> ${conf_file}
            echo "HOSTRUNFILE = ${conf_dir}/hosts-run" >> $conf_file
            echo "HOSTNOHEADFILE = ${conf_dir}/hosts-run-nohead" >> $conf_file
            echo "BOOTFILE = ${conf_dir}/boot" >> $conf_file
            echo "LOGDIR = ${logdir}" >> $conf_file
            echo "SCRATCHDIR = ${scratchdir}" >> $conf_file

            echo "BINARY = ${application}_${flavor}" >> ${conf_file}
            echo "MACE_START_PORT = ${mace_start_port}" >> ${conf_file}

            echo "run_time = ${runtime}" >> ${conf_file}
            echo "num_machines = ${t_machines}" >> ${conf_file}
            echo "num_server_machines = ${t_server_machines}" >> ${conf_file}
            echo "num_client_machines = ${t_client_machines}" >> ${conf_file}
            echo "num_servers = ${t_servers}" >> ${conf_file}
            echo "num_clients = ${t_clients}" >> ${conf_file}
            echo "num_contexts = ${t_buildings}" >> ${conf_file}
            
            echo "day_period = ${day_period}" >> ${conf_file}
            echo "day_join = ${day_join}" >> ${conf_file}
            echo "day_leave = ${day_leave}" >> ${conf_file}
            echo "day_error = ${day_error}" >> ${conf_file}
            echo "num_days = ${t_days}" >> ${conf_file}

            #echo "MAX_ASYNC_THREADS = ${t_threads}" >> ${conf_file}
            #echo "MAX_TRANSPORT_THREADS = ${t_threads}" >> ${conf_file}

            echo "SET_TCP_NODELAY = ${tcp_nodelay}" >> ${conf_file}


            #echo "ServiceConfig.TagServerAsync.NUM_BUILDINGS = ${t_buildings_per_server}" >> ${conf_file}
            #echo "ServiceConfig.TagServerAsync.NUM_ROOMS = ${t_rooms}" >> ${conf_file}
            #echo "ServiceConfig.TagServerAsync.MOVEMENT_PERIOD = ${server_movement_period}" >> ${conf_file}
            #echo "ServiceConfig.TagServerAsync.NUM_PRIMES = ${t_primes}" >> ${conf_file}
            #echo "ServiceConfig.TagServerAsync.EXIT_TIME = ${exit_time}" >> ${conf_file}


            #echo "ServiceConfig.TagClient.ONE_DAY = ${day_period}" >> ${conf_file}
            #echo "ServiceConfig.TagClient.NUM_DAYS = ${t_days}" >> ${conf_file}
            #echo "ServiceConfig.TagClient.MOVEMENT_PERIOD = ${server_movement_period}" >> ${conf_file}
            #echo "ServiceConfig.TagClient.MAP_REQUEST_PERIOD = ${client_request_period}" >> ${conf_file}
            #echo "ServiceConfig.TagClient.PREJOIN_WAIT_TIME = ${prejoin_wait_time}" >> ${conf_file}
            #echo "ServiceConfig.TagClient.EXIT_TIME = ${exit_time}" >> ${conf_file}
echo "WORKER_JOIN_WAIT_TIME = 1" >>  ${conf_file}
            echo "MACE_LOG_AUTO_SELECTORS = \"Accumulator GlobalStateCoordinator\"" >> ${conf_file}
            echo "MACE_LOG_ACCUMULATOR = 1000" >> ${conf_file}
            initial_server_size=$(($t_server_machines+1))
            echo "ServiceConfig.Throughput.NSENDERS = ${initial_server_size}" >>  ${conf_file}


            #echo "ServiceConfig.MicroBenchmark.NUM_EVENTS = ${t_events}" >> ${conf_file}
            #echo "ServiceConfig.MicroBenchmark.NUM_ITERATIONS = ${t_iterations}" >> ${conf_file}

            #echo "ServiceConfig.MicroBenchmark.NUM_PAYLOAD = ${t_payload}" >> ${conf_file}

            # copy the param file for clients
            cp ${conf_file} ${conf_client_file}
            echo -e "\n# Specific parameters for client" >> ${conf_client_file}
            echo "ServiceConfig.Throughput.message_length = 1" >> ${conf_client_file}
            echo "lib.MApplication.initial_size = 1" >> ${conf_client_file}
            echo "ServiceConfig.Throughput.role = 1" >>  ${conf_client_file}




            echo -e "\n# Specific parameters for server" >> ${conf_file}

            #echo "EVENT_LIFE_TIME = 1" >> ${conf_file}
            #echo "EVENT_READY_COMMIT = 1" >> ${conf_file}


            echo "lib.MApplication.services = Throughput" >> ${conf_file}
            echo "lib.MApplication.initial_size = ${initial_server_size}" >> ${conf_file}
            echo "ServiceConfig.Throughput.role = 2" >>  ${conf_file}
            #echo "lib.MApplication.debug = 1" >> ${conf_file}

            # print out bootfile & param for servers
            echo -e "\e[00;31m\$ ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}\e[00m"
            ./configure.py -a ${application} -f ${flavor} -p ${mace_start_port} -o ${conf_file} -c ${conf_client_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}

            if [[ $? -ne 0 ]]; then
              echo "Error occurred while processing ./configure-${application}.py. Terminated."
              exit 1;
            fi
            
            #exit 0

            echo -e "\e[00;31m\$ ./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -m -i n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_buildings}-p${t_primes}\e[00m"
            #./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -m -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_buildings}-p${t_primes}
            ./master.py -a ${application} -f ${flavor} -p ${conf_file} -q ${conf_client_file} -i ${application}-${flavor}-${id}-n${t_server_machines}-m${t_client_machines}-s${t_servers}-c${t_clients}-b${t_buildings}-p${t_primes}

            sleep 5

          done # end of nruns
        done # end of total_events
      done # end of t_contexts
    done
  done
done
