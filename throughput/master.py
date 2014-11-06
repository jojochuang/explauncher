#!/usr/bin/python2.7

from optparse import OptionParser
import logging
import datetime
import signal
import sys

import Utils

logger = logging.getLogger('Benchmark.Master')


def main(options):
    """
    Main module of master-microbenchmark.
    """

    # Read param file
    param = Utils.param_reader(options.paramfile)

    # Register for monitor
    if options.monitor:
        machines = Utils.get_machines(param["HOSTRUNFILE"], int(param["num_machines"]))
        r = Utils.shell_exec('curl -s http://macesystems.cs.purdue.edu/manage/register/{}/{}/{} | tail -n1'.format(
            param["USER"],
            Utils.implode("-", machines),
            param["run_time"]))
        assert r.strip() == "SUCCESS", "Machine register failed. Resulted status is %s." % r


    # Create directory for storing logs
    log_name = datetime.datetime.now().strftime("%Y%m%d-%H-%M-%S")
    log_dir = "%s/%s-%s" % (param["LOGDIR"], options.identifier, log_name)

    Utils.mkdirp(log_dir)    

    console_log = "%s/console.log" % log_dir
    Utils.configureLogging('Benchmark', output_file=console_log)

    logger.info("log_dir = %s", log_dir)

    Utils.copyfile(log_dir, options.paramfile)
    Utils.copyfile(log_dir, options.clientfile)
    Utils.copyfile(log_dir, param["HOSTRUNFILE"])
    Utils.copyfile(log_dir, param["HOSTNOHEADFILE"])
    Utils.copyfile(log_dir, param["BOOTFILE"])

    # Killall the experiment
    cmd = 'killall python2.7 worker-run.py {binary}'.format(
            binary=param["BINARY"])
    Utils.shell_exec('pssh -v -p {num_machines} -P -t 30 -h {hostfile} {command}'.format(
        num_machines=param["num_machines"], 
        hostfile=param["HOSTRUNFILE"],
        command=cmd))

    # Clean up scratch directory
    cmd = "'rm -rvf %s'" % param["SCRATCHDIR"]
    Utils.shell_exec('{pssh_dir}/pssh -v -p {num_machines} -P -t 30 -h {hostfile} {command}'.format(
        pssh_dir=param["PSSHDIR"],
        num_machines=param["num_machines"], 
        hostfile=param["HOSTRUNFILE"],
        command=cmd))

    # Sync the conf/* if needed
    # Affected files are : boot hosts-run hosts-run-nohead params-run.conf
    if param["SYNC_CONF_FILES"] == "1":
        Utils.shell_exec('{pssh_dir}/pscp -v -h {hostfile} {bootfile} {confdir}'.format(
            pssh_dir=param["PSSHDIR"],
            hostfile=param["HOSTRUNFILE"],
            bootfile=param["BOOTFILE"],
            confdir=param["CONFDIR"]))

        Utils.shell_exec('{pssh_dir}/pscp -v -h {hostfile} {hostfile} {confdir}'.format(
            pssh_dir=param["PSSHDIR"],
            hostfile=param["HOSTRUNFILE"],
            confdir=param["CONFDIR"]))

        Utils.shell_exec('{pssh_dir}/pscp -v -h {hostfile} {hostnoheadfile} {confdir}'.format(
            pssh_dir=param["PSSHDIR"],
            hostfile=param["HOSTRUNFILE"],
            hostnoheadfile=param["HOSTNOHEADFILE"],
            confdir=param["CONFDIR"]))

        Utils.shell_exec('{pssh_dir}/pscp -v -h {hostfile} {conffile} {confdir}'.format(
            pssh_dir=param["PSSHDIR"],
            hostfile=param["HOSTRUNFILE"],
            conffile=param["CONFFILE"],
            confdir=param["CONFDIR"]))


    # Run worker-run-microbenchmark.py with PSSH
    # PSSH will be launched via fork() to catch Ctrl+C to stop the
    # experiment.
    cmd = '"ulimit -c unlimited; {bin}/worker-run.py -p {paramfile} -q {clientfile}"'.format(
            bin=param["BIN"],
            paramfile="%s/%s" % (param["BIN"], options.paramfile),
            clientfile="%s/%s" % (param["BIN"], options.clientfile))
    Utils.shell_launch('pssh -v -p {num_machines} -P -t {run_time} -h {hostfile} {command}'.format(
        num_machines=param["num_machines"], 
        run_time=int(param["run_time"]) + int(param["WORKER_JOIN_WAIT_TIME"]) + 
                 int(param["CLIENT_WAIT_TIME"]) + int(param["TOTAL_BOOT_TIME"]) + 10,
        hostfile=param["HOSTRUNFILE"],
        command=cmd))

    # Killall the experiment
    cmd = 'killall python2.7 worker-run.py {binary} sar worker-sar.sh'.format(
            binary=param["BINARY"])
    Utils.shell_exec('pssh -v -p {num_machines} -P -t 30 -h {hostfile} {command}'.format(
        num_machines=param["num_machines"], 
        hostfile=param["HOSTRUNFILE"],
        command=cmd))

    # Copying logs
    cmd = '{bin}/worker-log.py -p {paramfile} -l {logdir}'.format(
            bin=param["BIN"],
            paramfile="%s/%s" % (param["BIN"], options.paramfile),
            logdir=log_dir)

    Utils.shell_exec('ulimit -c unlimited; pssh -v -p {num_machines} -P -t {run_time} -h {hostfile} {command}'.format(
        num_machines=param["num_machines"], 
        run_time=param["run_time"],
        hostfile=param["HOSTRUNFILE"],
        command=cmd),
        verbose=False)

    # Adjust log directory permission
    Utils.shell_exec("chmod -R a+rwx %s" % log_dir)

    # Unregister for monitor
    if options.monitor:
        machines = Utils.get_machines(param["HOSTRUNFILE"], int(param["num_machines"]))
        r = Utils.shell_exec('curl -s http://macesystems.cs.purdue.edu/manage/unregister/{}/{} | tail -n1'.format(
            param["USER"],
            Utils.implode("-", machines)))
        assert r.strip() == "SUCCESS", "Machine register failed. Resulted status is %s." % r

    # Done

    logger.info("Done")


###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Microbenchmark experiment tool (master).")

    parser.add_option("-a", "--application", dest="app", action="store", type="string",
    help="Name of the application. e.g. microbenchmark.")
    parser.add_option("-f", "--flavor", dest="flavor", action="store", type="string",
    help="Type of the application. e.g. context.")
    parser.add_option("-p", "--paramfile", dest="paramfile", action="store", type="string", 
    help="Parameter file to run experiment.")
    parser.add_option("-q", "--clientfile", dest="clientfile", action="store", type="string", 
    help="Client parameter file to run experiment.")
    parser.add_option("-i", "--identifier", dest="identifier", action="store", type="string", default="test",
    help="Identifier of this experiments.")
    parser.add_option("-m", "--monitor", dest="monitor", action="store_true",
    help="Whether to register machines for status check.")


    (options, args) = parser.parse_args()

    # Check missing arguments

    if not options.app:
        parser.error("Missing --application")
    if not options.flavor:
        parser.error("Missing --flavor")
    if not options.paramfile:
        parser.error("Missing --paramfile")
    if not options.clientfile:
        parser.error("Missing --clientfile")

    main_start_time = Utils.unixTime()

    main(options)

    main_end_time = Utils.unixTime()

    logger.info("Total time : %f sec", main_end_time - main_start_time)
