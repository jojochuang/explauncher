#!/usr/bin/python2.7

from optparse import OptionParser
import logging

import Utils


logger = logging.getLogger('Benchmark.Configure')


def main(options):
    """
    Main module of configure-microbenchmark.
    """

    # Read host file
    ipaddr = []
    hostname = []

    with open(options.host, "r") as h:
        for line in h:
            ip = Utils.shell_exec("host %s | awk '{print $2}'" % line.strip(), verbose=False)
            #print("host = %s, ip = %s" % (line.strip(), ip.strip()))
            hostname.append(line.strip())
            ipaddr.append(ip.strip())

    assert len(ipaddr) > 0, "Number of machines in host file should exist at least one"
    assert len(ipaddr) >= options.machines, "number of machines in host file is smaller than --machines"

    # Write to output boot file (This is only for physical machines)
    with open(options.boot, "w") as f:
        # Write (id, time_to_boot, ip_addr, host_name)
        for i in range(options.machines):
            f.write( '{} {:.3f} {}:{} {}\n'.format(
                i, 
                (options.setuptime * (1.0 * i / options.machines)), 
                ipaddr[i % options.machines], 
                options.port+i,
                hostname[i % options.machines]))

    # Write to output host file
    with open(options.hostrun, "w") as f:
        with open(options.hostnohead, "w") as g:
            for i in range(options.machines):
                f.write("%s\n" % hostname[i])
                if i > 0:
                    g.write("%s\n" % hostname[i])

    # Write to output conf file (This is for nodes)
    with open(options.output, "a") as f:
        # print nodeset
        port = options.port
        for i in range(options.machines):
            f.write( 'nodeset = {}:{}\n'.format(
                ipaddr[i],
                port))
            port += 1

        # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
        f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

        # write down HEAD_IPADDR, which is the first node in the hosts file
        f.write( "HEAD_IPADDR = %s\n" % ipaddr[0] )

    return


###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Microbenchmark configure file generator.")

    parser.add_option("-a", "--application", dest="app", action="store", type="string",
    help="Name of the application. e.g. microbenchmark.")
    parser.add_option("-f", "--flavor", dest="flavor", action="store", type="string",
    help="Type of the application. e.g. context.")
    parser.add_option("-n", "--nodes", dest="nodes", action="store", type="int",
    help="Number of nodes. e.g. number of total processes.")
    parser.add_option("-m", "--machines", dest="machines", action="store", type="int",
    help="Number of physical machines. e.g. number of physical machines.")
    parser.add_option("-p", "--port", dest="port", action="store", type="int",
    help="Mace starting port.")
    parser.add_option("-o", "--output", dest="output", action="store", type="string",
    help="Output .conf file to append.")
    parser.add_option("-s", "--setuptime", dest="setuptime", action="store", type="int",
    help="Time to boot.")
    parser.add_option("-b", "--boot", dest="boot", action="store", type="string",
    help="Output boot file to write.")
    parser.add_option("-i", "--input", dest="host", action="store", type="string",
    help="Input file lists hosts.")
    parser.add_option("-j", "--hostrun", dest="hostrun", action="store", type="string",
    help="Output file that will list executing hosts.")
    parser.add_option("-k", "--hostnohead", dest="hostnohead", action="store", type="string",
    help="Output file that will list executing hosts excluding head node.")


    (options, args) = parser.parse_args()

    # Check missing arguments

    if not options.app:
        parser.error("Missing --application")
    if not options.flavor:
        parser.error("Missing --flavor")
    if not options.nodes:
        parser.error("Missing --nodes")
    if not options.machines:
        parser.error("Missing --machines")
    if not options.port:
        parser.error("Missing --port")
    if not options.output:
        parser.error("Missing --output")
    if not options.setuptime:
        parser.error("Missing --setuptime")
    if not options.boot:
        parser.error("Missing --boot")
    if not options.host:
        parser.error("Missing --input")
    if not options.hostrun:
        parser.error("Missing --hostrun")
    if not options.hostnohead:
        parser.error("Missing --hostnohead")

    # Initialize the logger
    Utils.configureLogging('Benchmark', decorate_header=False)

    main_start_time = Utils.unixTime()

    main(options)

    main_end_time = Utils.unixTime()

    #logger.info("Total time : %f sec", main_end_time - main_start_time)


    

