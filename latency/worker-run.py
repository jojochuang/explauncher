#!/usr/bin/python2.7

from optparse import OptionParser
from multiprocessing import Process
from time import sleep
import logging

import Utils

logger = logging.getLogger('Benchmark.Worker')

def execute_client(nid,boot_wait_time,ipaddr,hostname,app_type, param, paramfile,clientfile):
    logger.info("ID = %s SleepTime = %s ipaddr = %s hostname = %s app_type = %s" % (nid, boot_wait_time, ipaddr, hostname, app_type))

    assert app_type == "client"


    # re-load parameters for the specific server
    param = Utils.param_reader(options.clientfile)

    # Sleep
    if param["flavor"] == "nacho":
        sleep_time = float(boot_wait_time)+int(param["WORKER_JOIN_WAIT_TIME"])
        sleep_time += int(param["CLIENT_WAIT_TIME"])
    elif param["flavor"] == "context":
        sleep_time = float(boot_wait_time)
        sleep_time += int(param["CLIENT_WAIT_TIME"])+int(param["WORKER_JOIN_WAIT_TIME"])

    logger.info("Sleeping %d...", sleep_time )

    #sleep_time=0
    sleep( sleep_time )
  
    # Log filename
    logdir = param["SCRATCHDIR"]

    # Create and move into subdir
    subdir='{}/client-{}'.format(logdir,nid)
    Utils.mkdirp(subdir)
    Utils.chdir(subdir)

    # Run the application
    start_time = Utils.unixTime()

    app = "%s/%s" % (param["BIN"], param["BINARY"])

    server_scale = int( param["lib.MApplication.initial_size"] )
    nservers = int( param["SERVER_LOGICAL_NODES"] )
    sender_id = int(nid) - server_scale * nservers
    receivers = param["LAUNCHER.receiver_addr"]

    #print "len=%d, nid=%d, nservers=%d, server_scale=%d" % ( len(receivers), int(nid) , nservers, server_scale )


    # TODO: translate client id to corresponding address
    raddr = ""
    if param["flavor"] == "nacho":
      raddr = receivers[ int(nid) - len(receivers) ]
    elif param["flavor"] == "context":
      raddr = receivers





    logfile = '{}/client-{}-{}.log'.format(
            logdir,
            hostname,
            nid)
    logger.info('$ {application} {pfile} -service {service} -ServiceConfig.ParkRangerClient.SENDER_ID {sid} -MACE_PORT {port} -ServiceConfig.KeyValueClient.DHT_NODES {raddr}'.format(
        application=app,
        pfile=clientfile,
        service=param["client_service"],
        sid=sender_id,
        port=ipaddr.strip().split(":")[1],
        raddr=raddr))
    r = Utils.process_exec('{application} {pfile} -service {service} -ServiceConfig.ParkRangerClient.SENDER_ID {sid} -MACE_PORT {port} -ServiceConfig.KeyValueClient.DHT_NODES {raddr}'.format(
        application=app,
        pfile=clientfile,
        service=param["client_service"],
        sid=sender_id,
        port=ipaddr.strip().split(":")[1],
        raddr=raddr),
        log=logfile)

    end_time = Utils.unixTime()

    logger.info("Process %s exited." % nid)
    logger.info("Total execution time : %f sec", end_time - start_time)

import os
def execute_server(nid,boot_wait_time,ipaddr,hostname,app_type, param, paramfile):
    logger.info("ID = %s SleepTime = %s ipaddr = %s hostname = %s app_type = %s" % (nid, boot_wait_time, ipaddr, hostname, app_type))

    assert app_type == "server"

    # Sleep
    if param["flavor"] == "nacho":
        sleep_time = float(boot_wait_time)+int(param["WORKER_JOIN_WAIT_TIME"])
    elif param["flavor"] == "context":
        sleep_time = float(boot_wait_time)

    logger.info("Sleeping %d...", sleep_time )

    sleep( sleep_time )
  
    # Log filename
    logdir = param["SCRATCHDIR"]

    # re-load parameters for the specific server
    #param = Utils.param_reader(options.paramfile)

    # Create and move into subdir
    subdir='{}/client-{}'.format(logdir,nid)
    Utils.mkdirp(subdir)
    Utils.chdir(subdir)

    # Run the application
    start_time = Utils.unixTime()

    app = "%s/%s" % (param["BIN"], param["BINARY"])

    # determine which bootstrapping node to associate with
    server_scale = int( param["lib.MApplication.initial_size"] )
    nservers = int( param["SERVER_LOGICAL_NODES"] )
    assert server_scale > 1
    sid = (int( nid ) - nservers) / ( server_scale-1)

    #pfn = paramfile + str( sid )
    pfn = paramfile
    logfile = '{}/server-{}-{}.log'.format(
            logdir,
            hostname,
            nid)
    logger.info('$ {application} {pfile} -service {service}  -MACE_PORT {port}'.format(
        application=app,
        pfile=pfn,
        service=param["server_service"],
        port=ipaddr.strip().split(":")[1]))
    r = Utils.process_exec('{application} {pfile} -service {service}  -MACE_PORT {port}  '.format(
        application=app,
        pfile=pfn,
        service=param["server_service"],
        port=ipaddr.strip().split(":")[1]),
        log=logfile)

    end_time = Utils.unixTime()

    logger.info("Process %s exited." % nid)
    logger.info("Total execution time : %f sec", end_time - start_time)
    

def execute_head(nid,boot_wait_time,ipaddr,hostname,app_type, param, paramfile):
    logger.info("ID = %s SleepTime = %s ipaddr = %s hostname = %s" % (nid, boot_wait_time, ipaddr, hostname))

    assert app_type == "head"

    # Sleep
    logger.info("Sleeping %s...", boot_wait_time)
    sleep_time = float(boot_wait_time)
    if param["flavor"] == "nacho":
        sleep_time += 0
    elif param["flavor"] == "context":
        # the fullcontext runtime assumes all peer nodes are ready when the head starts
        sleep_time += int(param["WORKER_JOIN_WAIT_TIME"])
    sleep( sleep_time )

    # Log filename
    logdir = param["SCRATCHDIR"]
    logfile = '{}/head-{}-{}.log'.format(
            logdir,
            hostname,
            nid)

    # Create and move into subdir
    subdir='{}/client-{}'.format(logdir,nid)
    Utils.mkdirp(subdir)
    Utils.chdir(subdir)

    # Run the application

    start_time = Utils.unixTime()

    #sid = nid

    # re-load parameters for the specific server
    #param = Utils.param_reader(options.paramfile)

    #pfn = paramfile + str( sid )
    pfn = paramfile
    app = "%s/%s" % (param["BIN"], param["BINARY"])
    r = Utils.process_exec('{application} {pfile} -service {service} -MACE_PORT {port}'.format(
        application=app,
        pfile=pfn,
        service=param["server_service"],
        port=ipaddr.strip().split(":")[1]),
        log=logfile)

    end_time = Utils.unixTime()
    
    logger.info("Process %s exited." % nid)
    logger.info("Total execution time : %f sec", end_time - start_time)

    # If the head is killed, kill the rest of the machines.

    logger.info("Head is trying to kill rest of the machines.")

    cmd = 'killall python2.7 {binary}'.format(
            binary=param["BINARY"])
    Utils.shell_exec('{pssh_dir}/pssh -v -p {num_machines} -P -t 30 -h {hostfile} {command}'.format(
        pssh_dir=param["PSSHDIR"],
        num_machines=param["num_machines"], 
        hostfile=param["HOSTNOHEADFILE"],
        command=cmd))

    logger.info("Done killing other nodes")


def main(options):
    """
    Main module of worker-run--microbenchmark.
    """

    logger.info("enter main")
    # Some initialization
    param = Utils.param_reader(options.paramfile)

    if param["EC2"] == "1":
        myhost = Utils.shell_exec('hostname -f', verbose=False)
    else:
        myhost = Utils.shell_exec('hostname -s', verbose=False)
    myhost = myhost.strip()
    Utils.mkdirp(param["SCRATCHDIR"])
    Utils.chdir(param["SCRATCHDIR"])
    logdir=param["SCRATCHDIR"]


    # Configure log
    Utils.configureLogging('Benchmark', output_file='{}-console.log'.format(myhost),
            log_stdout=False,
            decorate_header=False)
    logger.info("myhost = %s" % myhost)

    if param["EC2"] == 1:
      # Launching sar
      Utils.shell_exec('{bin}/worker-sar.sh {logdir} {logname} {interval} {runtime}'.format(
          binary = param["BINARY"],
          logdir = param["SCRATCHDIR"],
          logname = "client-%s-sar.log",
          interval = "1",
          runtime = param["run_time"]))


    # Read boot file and launch the application.
    # As defined in the boot file, you will run the process with Popen (in Utils.py)
    plist = []
    with open(param["BOOTFILE"]) as f:
        for line in f:
            logger.info("processing boot = %s" % line)
            #node_id, time_to_boot, ip_addr, hostname
            nid, boot_wait_time, ipaddr, hostname, app_type = line.strip().split(" ")
            if myhost != hostname:
              continue

            if app_type == "head":
                p = Process(target=execute_head, args=(nid, boot_wait_time, ipaddr, hostname, app_type, param, options.paramfile))
                plist.append(p)
            elif app_type == "server":
                logger.info("launching worker nid = %s" % nid)
                if int(nid) > 0:
                    p = Process(target=execute_server, args=(nid, boot_wait_time, ipaddr, hostname, app_type, param, options.paramfile))
                    plist.append(p)

            elif app_type == "client":
                logger.info("launching worker nid = %s" % nid)
                if int(nid) > 0:
                    p = Process(target=execute_client, args=(nid, boot_wait_time, ipaddr, hostname, app_type, param, options.paramfile, options.clientfile))
                    plist.append(p)
            else:
              raise Exception("unknown app type=" + app_type)

        # Now start process
        for p in plist:
            p.start()

        # Now wait process terminates
        for p in plist:
            p.join()


    # Killing sar
    Utils.shell_exec('killall worker-sar.sh sar')


###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Microbenchmark experiment tool (worker).")

    parser.add_option("-p", "--paramfile", dest="paramfile", action="store", type="string", 
        help="Parameter file to run experiment.")
    parser.add_option("-q", "--clientfile", dest="clientfile", action="store", type="string", 
        help="Client parameter file to run experiment.")

    (options, args) = parser.parse_args()

    # Check missing arguments

    if not options.paramfile:
        parser.error("Missing --paramfile")
    if not options.clientfile:
        parser.error("Missing --clientfile")

    main_start_time = Utils.unixTime()

    main(options)

    main_end_time = Utils.unixTime()

    #logger.info("Total time : %f sec", main_end_time - main_start_time)

