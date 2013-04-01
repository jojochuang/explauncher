#!/usr/bin/python2.7

from optparse import OptionParser
from multiprocessing import Process
from time import sleep
import logging

import Utils

logger = logging.getLogger('Benchmark.Worker')

def execute_worker(nid,boot_wait_time,ipaddr,hostname,app_type, param, paramfile,clientfile):
    logger.info("ID = %s SleepTime = %s ipaddr = %s hostname = %s app_type = %s" % (nid, boot_wait_time, ipaddr, hostname, app_type))

    assert app_type == "server" or app_type == "client"

    # Sleep
    logger.info("Sleeping %s...", float(boot_wait_time)+int(param["WORKER_JOIN_WAIT_TIME"]))

    #if float(boot_wait_time) > int(param["WORKER_JOIN_WAIT_TIME"]):
    sleep(float(boot_wait_time))
    #else:
    sleep(int(param["WORKER_JOIN_WAIT_TIME"]))

    # Log filename
    logdir = param["SCRATCHDIR"]

    # Create and move into subdir
    subdir='{}/client-{}'.format(logdir,nid)
    Utils.mkdirp(subdir)
    Utils.chdir(subdir)

    # Run the application
    app = "%s/%s" % (param["BIN"], param["BINARY"])

    if app_type == "server":
        logfile = '{}/client-{}-server-{}.log'.format(
                logdir,
                hostname,
                nid)
        logger.info('$ {application} {pfile} -service {service} -lib.ContextJobApplication.services {service} -MACE_PORT {port}'.format(
            application=app,
            pfile=paramfile,
            service=param["server_service"],
            port=ipaddr.strip().split(":")[1]))
        r = Utils.process_exec('{application} {pfile} -service {service} -MACE_PORT {port}'.format(
            application=app,
            pfile=paramfile,
            service=param["server_service"],
            port=ipaddr.strip().split(":")[1]),
            log=logfile)
    else: # client
        logfile = '{}/client-{}-player-{}.log'.format(
                logdir,
                hostname,
                nid)
        logger.info('$ {application} {pfile} -service {service} -ServiceConfig.TagClient.CLIENT_ID {cid} -nodeset {ip}:{port} -mapping 0:Global -MACE_PORT {port}'.format(
            application=app,
            pfile=clientfile,
            service=param["client_service"],
            cid=nid,
            ip=ipaddr.strip().split(":")[0],
            port=ipaddr.strip().split(":")[1]))
        r = Utils.process_exec('{application} {pfile} -service {service} -ServiceConfig.TagClient.CLIENT_ID {cid} -nodeset {ip}:{port} -mapping 0:Global -MACE_PORT {port}'.format(
            application=app,
            pfile=clientfile,
            service=param["client_service"],
            cid=nid,
            ip=ipaddr.strip().split(":")[0],
            port=ipaddr.strip().split(":")[1]),
            log=logfile)
    logger.info("Process %s exited." % nid)
    

def execute_head(nid,boot_wait_time,ipaddr,hostname,app_type, param, paramfile):
    logger.info("ID = %s SleepTime = %s ipaddr = %s hostname = %s" % (nid, boot_wait_time, ipaddr, hostname))

    assert app_type == "head"

    # Sleep
    logger.info("Sleeping %s...", boot_wait_time)
    sleep(float(boot_wait_time))

    # Log filename
    logdir = param["SCRATCHDIR"]
    logfile = '{}/client-{}-head-{}.log'.format(
            logdir,
            hostname,
            nid)

    # Create and move into subdir
    subdir='{}/client-{}'.format(logdir,nid)
    Utils.mkdirp(subdir)
    Utils.chdir(subdir)

    # Run the application
    app = "%s/%s" % (param["BIN"], param["BINARY"])
    #cmd = '{application} {pfile} -MACE_PORT {port}'.format(
        #application=app,
        #pfile=paramfile,
        #port=ipaddr.strip().split(":")[1])
    #logger.info("cmd = %s" % cmd)
    r = Utils.process_exec('{application} {pfile} -service {service} -MACE_PORT {port}'.format(
        application=app,
        service=param["head_service"],
        pfile=paramfile,
        port=ipaddr.strip().split(":")[1]),
        log=logfile)
    logger.info("Process %s exited." % nid)

    # If the head is killed, kill the rest of the machines.

    logger.info("Head is trying to kill read of the machines.")

    cmd = 'killall python2.7 worker-run.py {binary}'.format(
            binary=param["BINARY"])
    Utils.shell_exec('pssh -v -p {num_machines} -P -t 30 -h {hostfile} {command}'.format(
        num_machines=param["num_machines"], 
        hostfile=param["HOSTNOHEADFILE"],
        command=cmd))

    logger.info("Done killing other nodes")


def main(options):
    """
    Main module of worker-run--microbenchmark.
    """

    # Some initialization
    param = Utils.param_reader(options.paramfile)

    myhost = Utils.shell_exec('hostname -s', verbose=False)
    #ulimit = Utils.shell_exec('ulimit -n 10000; ulimit -a', verbose=False)
    #ulimit = Utils.shell_exec('ulimit -a', verbose=False)
    myhost = myhost.strip()
    Utils.mkdirp(param["SCRATCHDIR"])
    Utils.chdir(param["SCRATCHDIR"])
    logdir=param["SCRATCHDIR"]


    # Configure log
    Utils.configureLogging('Benchmark', output_file='client-{}-console.log'.format(myhost),
            log_stdout=False,
            decorate_header=False)
    logger.info("myhost = %s" % myhost)
    #logger.info("ulimit\n%s\n" % ulimit)

    # Read boot file and launch the application.
    # As defined in the boot file, you will run the process with Popen (in Utils.py)
    plist = []
    with open(param["BOOTFILE"]) as f:
        for line in f:
            logger.info("processing boot = %s" % line)
            #node_id, time_to_boot, ip_addr, hostname
            nid, boot_wait_time, ipaddr, hostname, app_type = line.strip().split(" ")
            if myhost == hostname:
                if nid == "0":
                    p = Process(target=execute_head, args=(nid, boot_wait_time, ipaddr, hostname, app_type, param, options.paramfile))
                    plist.append(p)
                else:
                    logger.info("launching worker nid = %s" % nid)
                    if int(nid) > 0:
                        p = Process(target=execute_worker, args=(nid, boot_wait_time, ipaddr, hostname, app_type, param, options.paramfile, options.clientfile))
                        plist.append(p)

        # Now start process
        for p in plist:
            p.start()

        # Now wait process terminates
        for p in plist:
            p.join()







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

