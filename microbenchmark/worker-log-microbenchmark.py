#!/usr/bin/python2.7

from optparse import OptionParser
import logging
import Utils

logger = logging.getLogger('Benchmark.LogCollector')

def main(options):
    """
    Main module of worker-log-microbenchmark
    """

    # Read param file
    param = Utils.param_reader(options.paramfile)

    logger.info("SCRATCHDIR = %s LOGDIR = %s" % (param["SCRATCHDIR"], options.logdir))

    Utils.chdir(param["SCRATCHDIR"])
    Utils.shell_exec("gzip *.log")
    Utils.shell_exec("cp -v %s/*.gz %s" % (param["SCRATCHDIR"], options.logdir))



###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Microbenchmark experiment log collector (worker).")

    parser.add_option("-p", "--paramfile", dest="paramfile", action="store", type="string", 
    help="Parameter file to run experiment.")
    parser.add_option("-l", "--logdir", dest="logdir", action="store", type="string",
    help="Directory of where log is located.")

    (options, args) = parser.parse_args()

    # Check missing arguments

    if not options.paramfile:
        parser.error("Missing --paramfile")
    if not options.logdir:
        parser.error("Missing --logdir")

    Utils.configureLogging('Benchmark',
            decorate_header=False)

    main_start_time = Utils.unixTime()

    main(options)

    main_end_time = Utils.unixTime()

    #logger.info("Total time : %f sec", main_end_time - main_start_time)
