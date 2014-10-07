#!/bin/bash

# This is the script that runs multiple microbenchmarks in fullcontext.

mace_start_port=4000
boottime=1   # total time to boot.
#runtime=100  # maximum runtime
#runtime=1500  # maximum runtime
#runtime=800  # maximum runtime
runtime=300  # maximum runtime
earlyquit=1  # Whether to support early quit (yes)
tcp_nodelay=1   # If this is 1, you will disable Nagle's algorithm. It will provide better throughput in smaller messages.
ec2=0        # set this if you are experimenting on EC2
#shuffle_hosts=1  # set this to 1 to shuffle hosts file.
shuffle_hosts=0  # set this to 1 to shuffle hosts file.

nruns=1      # number of replicated runs
#nruns=2      # number of replicated runs
#nruns=4      # number of replicated runs
#nruns=5      # number of replicated runs


#samehead=1


if [ $# -eq 0 ]; then
    id="default"
else
    id=$1
fi


application="microbenchmark"

if [[ $ec2 -eq 0 ]]; then
  user="chuangw"
  home="/homes/chuangw"                                       # Home directory
  bin="/homes/chuangw/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir="/u/tiberius06_s/chuangw/logs/${application}"        # Log collection directory
  scratchdir="/scratch/chuangw/tmp/${application}"            # Scratch directory location
  psshdir="/homes/chuangw/pssh/bin"
else
  user="ubuntu"
  home="/home/ubuntu"                                       # Home directory
  bin="/home/ubuntu/benchmark/${application}"               # Default explauncher experiment directory. Also, binary executable exists at this directory.

  logdir="/home/ubuntu/logs/${application}"        # Log collection directory
  scratchdir="/run/shm/tmp/${application}"            # Scratch directory location
  psshdir="/home/ubuntu/pssh-2.2/bin"
fi

conf_dir="${bin}/conf"                    # Configuration directory
conf_orig_file="conf/params-basic.conf"   # Relative directory of conf_orig_file
conf_file="conf/params-run.conf"
host_orig_file="conf/hosts"
host_run_file="conf/hosts-run"
host_nohead_file="conf/hosts-run-nohead"
boot_file="conf/boot"

for flavor in context; do
  #for t_primes in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096; do
  #for t_primes in 0 10 20 40 80 160; do
  #for t_primes in 40 80 160; do
  #for t_primes in 0 100 150 200 300 400; do
  for t_primes in 100 150 200; do
  #for t_primes in 50; do
  #for t_primes in 50 100 150 200; do
  #for t_primes in 0 50 100 150 200; do
  #for t_primes in 0 100 200 300 400; do
  #for t_primes in 0; do
  #for t_primes in 150; do

    #for t_payload in 100000 200000 400000 800000 1600000 3200000 6400000 12800000; do       # size of bytes of each context space. set this if you want to test migration effect.
    #for t_payload in 0 100000000 200000000 400000000; do       # size of bytes of each context space. set this if you want to test migration effect.
    #for t_payload in 102400000 204800000 409600000; do       # size of bytes of each context space. set this if you want to test migration effect.
    #for t_payload in 12800000; do
    #for t_payload in 100000000; do
    for t_payload in 0; do

    #for t_nodes in 4; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 8; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 16; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 1 2 4; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 0; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 1 2; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 0 1 2 4 8; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 128 64 32; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 64 32 16; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 128; do        # number of physical machines you will be using (excluding head node)
    for t_nodes in 4; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 16 8 4; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 16 8 4 2 1; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 1 2 4 8; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 1; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 2; do        # number of physical machines you will be using (excluding head node)
    #for t_nodes in 10; do        # number of physical machines you will be using (excluding head node)

      samehead=0

      # Set this 1 if you want to start all the contexts at first node.
      # CAUTION ! Do this only for testing scale-out-and-in migration
      #
      #start_same_node=1

      if [[ $t_nodes -eq 0 ]]; then
        samehead=1
        t_nodes=1
      fi

      if [[ $samehead -eq 1 ]]; then
        t_machines=1
      else
        t_machines=$(($t_nodes+1)) # adding one more machine for head node dedication
      fi

      #t_contexts=1

      #for (( c=1; c <= $ncontexts; c++ )); do
      #for t_contexts in 2; do   # number of context per each physical machine
      #for t_contexts in 2; do   # number of context per each physical machine
      #for t_contexts in 1 2; do   # number of context per each physical machine
      #for t_contexts in 1 2 4 8 16; do   # number of context per each physical machine
      #for t_contexts in 64 128 256 512; do   # number of context per each physical machine
      #for t_contexts in 1 2 4 8 16; do   # number of context per each physical machine
      #for t_contexts in 1 2 4 8 16 32 64 128 256 512 1024; do   # number of context per each physical machine
      #for t_contexts in 2 4 8; do   # number of context per each physical machine
      #for t_contexts in 2; do   # number of context per each physical machine
      #for t_totcontexts in 160; do  # Cloud and tiberius (up to N=10)
      #for t_totcontexts in 32; do    # Amazon EC2. (up to N=16)
      #for t_totcontexts in 256; do    # Amazon EC2. (up to N=16)
      for t_totcontexts in 128; do    # Amazon EC2. (up to N=16)
        t_contexts=$(($t_totcontexts/$t_nodes))

        t_groups=$(($t_contexts * $t_nodes))

        t_iterations=10

        #for total_events in 10000000; do # Recommended for migration test
        #for total_events in 1000000; do # Recommended for other cpuload test
        #for total_events in 50000; do # Recommended for other cpuload test
        for total_events in 500000; do # Recommended for EC2 group test

          t_events=$(( $total_events / $t_iterations / $t_groups ))

          #t_threads=$(($total_events * 2 / $t_nodes ))
          t_threads=$(($t_contexts * 2))
          if [ $t_threads -le 64 ]; then
            t_threads=64
          fi

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
            echo "CONFFILE = ${conf_dir}/params-run.conf" >> $conf_file
            echo "LOGDIR = ${logdir}" >> $conf_file
            echo "SCRATCHDIR = ${scratchdir}" >> $conf_file
            echo "PSSHDIR = ${psshdir}" >> $conf_file

            echo "BINARY = ${application}_${flavor}" >> ${conf_file}
            echo "MACE_START_PORT = ${mace_start_port}" >> ${conf_file}
            echo "num_nodes = ${t_nodes}" >> ${conf_file}
            echo "num_machines = ${t_machines}" >> ${conf_file}
            echo "run_time = ${runtime}" >> ${conf_file}
            echo "num_groups = ${t_groups}" >> ${conf_file}
            echo "num_contexts = ${t_contexts}" >> ${conf_file}
            echo "EARLY_QUIT = ${earlyquit}" >> ${conf_file}
            echo "TOTAL_NUM_EVENTS = ${total_events}" >> ${conf_file}

            echo "MAX_ASYNC_THREADS = ${t_threads}" >> ${conf_file}
            echo "MAX_TRANSPORT_THREADS = ${t_threads}" >> ${conf_file}

            echo "SET_TCP_NODELAY = ${tcp_nodelay}" >> ${conf_file}

            echo "ServiceConfig.MicroBenchmark.NUM_GROUPS = ${t_groups}" >> ${conf_file}
            echo "ServiceConfig.MicroBenchmark.NUM_PRIMES = ${t_primes}" >> ${conf_file}
            echo "ServiceConfig.MicroBenchmark.NUM_EVENTS = ${t_events}" >> ${conf_file}
            echo "ServiceConfig.MicroBenchmark.NUM_ITERATIONS = ${t_iterations}" >> ${conf_file}

            echo "ServiceConfig.MicroBenchmark.NUM_PAYLOAD = ${t_payload}" >> ${conf_file}

            # print out SYNC_CONF_FILES = 1 if ec2 is on
            if [[ $ec2 -eq 1 ]]; then
              echo "EC2 = 1" >> ${conf_file}
              echo "SYNC_CONF_FILES = 1" >> ${conf_file}
            else
              echo "EC2 = 0" >> ${conf_file}
              echo "SYNC_CONF_FILES = 0" >> ${conf_file}
            fi

            # print out SHUFFLE_HOSTS = 1 if shuffle_hosts is on
            if [[ $shuffle_hosts -eq 1 ]]; then
              echo "SHUFFLE_HOSTS = 1" >> ${conf_file}
            else
              echo "SHUFFLE_HOSTS = 0" >> ${conf_file}
            fi

            # print out bootfile & nodeset

            echo -e "\e[00;31m\$ ./configure.py -a ${application} -f ${flavor} -n ${t_nodes} -m ${t_machines} -p ${mace_start_port} -o ${conf_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}\e[00m"
            ./configure.py -a ${application} -f ${flavor} -n ${t_nodes} -m ${t_machines} -p ${mace_start_port} -o ${conf_file} -i ${host_orig_file} -j ${host_run_file} -k ${host_nohead_file} -s ${boottime} -b ${boot_file}

            if [[ $? -ne 0 ]]; then
              echo "Error occurred while processing ./configure.py. Terminated."
              exit 1;
            fi

            # print out mappings
            # CHANGE THIS TO BE CREATED BY ./configure.py !!!!!!!!!!

            if [[ $samehead -eq 1 ]]; then
              key_start=0
              key_end=$t_nodes
            else
              key_start=1
              key_end=$(($t_nodes+1))
            fi

            if [ $flavor == "context" ]; then
                value=0
                initial_size=$(($key_end+1))
                echo "lib.MApplication.initial_size = $initial_size" >> ${conf_file}
                for (( key=$key_start; key < $key_end; key++ )); do
                  for (( c=1; c <= $t_contexts; c++ )); do

                    if [[ $start_same_node -eq 1 ]]; then
                      echo "mapping = ${key_start}:Group[${value}]" >> ${conf_file}
                      echo "lib.MApplication.MicroBenchmark.mapping = ${key_start}:Group[${value}]" >> ${conf_file}
                    else
                      echo "mapping = ${key}:Group[${value}]" >> ${conf_file}
                      echo "lib.MApplication.MicroBenchmark.mapping = ${key}:Group[${value}]" >> ${conf_file}
                    fi
                    value=$(($value+1))
                  done
                done

                # Add one more group for dedicated event launcher.
                echo "mapping = 0:Group[${value}]" >> ${conf_file}
                echo "lib.MApplication.MicroBenchmark.mapping = 0:Group[${value}]" >> ${conf_file}

            fi

            # For correct printing
            if [[ $samehead -eq 1 ]]; then
              t_nodes=0
            fi

            if [[ $ec2 -eq 0 ]]; then
              # use monitor
              echo -e "\e[00;31m\$ ./master.py -a ${application} -f ${flavor} -p ${conf_file} -m -i n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}\e[00m"
              #./master.py -a ${application} -f ${flavor} -p ${conf_file} -m -i ${application}-${flavor}-${id}-n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}
              ./master.py -a ${application} -f ${flavor} -p ${conf_file} -i ${application}-${flavor}-${id}-n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}

            else
              # do not use monitor
              echo -e "\e[00;31m\$ ./master.py -a ${application} -f ${flavor} -p ${conf_file} -i n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}\e[00m"
              ./master.py -a ${application} -f ${flavor} -p ${conf_file} -i ${application}-${flavor}-${id}-n${t_nodes}-c${t_contexts}-p${t_primes}-e${total_events}-l${t_payload}
            fi

            sleep 5

          done # end of nruns
        done # end of total_events

        t_contexts=$(($t_contexts*2))

      done # end of t_contexts
    done
  done
  done
done

