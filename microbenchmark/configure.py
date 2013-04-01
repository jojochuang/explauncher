#!/usr/bin/python2.7

from optparse import OptionParser
import logging

import Utils


logger = logging.getLogger('Benchmark.Configure')


def migrate(line_id, time, service_id, group_id, target_addr, f):
    f.write('migrate{}.time = {}\n'.format(
        line_id,
        time))
    f.write('migrate{}.service = {}\n'.format(
        line_id,
        service_id))
    f.write('migrate{}.dest = {}\n'.format(
        line_id,
        target_addr))
    f.write('migrate{}.contexts = Group[{}]\n'.format(
        line_id,
        group_id))
    f.write('\n')
    return
                
def main(options):
    """
    Main module of configure-microbenchmark.
    """

    # Read param file before append
    param = Utils.param_reader(options.paramfile)

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
    with open(options.paramfile, "a") as f:
        nodeaddr = []
        # print nodeset
        port = options.port
        for i in range(options.machines):
            f.write( 'nodeset = {}:{}\n'.format(
                ipaddr[i],
                port))
            f.write( 'lib.ContextJobApplication.nodeset = IPV4/{}:{}\n'.format(
                ipaddr[i],
                port))
            nodeaddr.append("%s:%s" % ( ipaddr[i], port) )
            port += 1

        # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
        f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

        # write down HEAD_IPADDR, which is the first node in the hosts file
        f.write( "HEAD_IPADDR = %s\n" % ipaddr[0] )

        # Write planned migration.
        if param.get('MIGRATION', '0') == '1':
            # Read values
            nnodes = options.nodes
            ngroups = int(param["num_groups"])
            ncontexts = int(param["num_contexts"])
            #print("ngroups = %s ncontexts = %s nnodes = %s\n" % (ngroups, ncontexts, nnodes))

            # Make sure number of node is > 1.
            assert nnodes > 1, "Number of nodes is insufficient"
            assert ngroups == nnodes * ncontexts, "ngroups != nnodes * ncontexts"

            # Create script
            if param["MIGRATION_TYPE"] == "SWAP_ITERATIVE":
                # Read additional values
                period = int(param["MIGRATION_PERIOD"])
                start = int(param["MIGRATION_START_TIME"])
                end = int(param["MIGRATION_END_TIME"])

                t = start
                lid = 0 # line_id
                while t < end:
                    # Forward swap
                    for gid in range(ngroups):
                        if t >= end:
                            break
                        # move gid to reverse of the gid's address

                        #print("gid = %s gid' = %s\n" % (gid, (ngroups-gid-1)/ncontexts + 1))
                        migrate(lid,t,0,gid,nodeaddr[ (ngroups-gid-1)/ncontexts + 1 ],f)
                        lid += 1
                        t += period
                        
                    # Reverse swap
                    for gid in range(ngroups):
                        if t >= end:
                            break
                        # move gid to reverse of the gid's address
                        migrate(lid,t,0,gid,nodeaddr[ gid/ncontexts + 1 ],f)
                        lid += 1
                        t += period

                # Now print out migrate keys
                if lid > 0:
                    f.write("lib.ContextJobApplication.timed_migrate =");
                    for i in range(lid):
                        f.write(' migrate{}'.format(i))

                    f.write("\n")

            elif param["MIGRATION_TYPE"] == "SWAP_ONCE":
                # Read additional values
                t = int(param["MIGRATION_START_TIME"])
                lid = 0 # line_id

                for gid in range(ngroups):
                    # move gid to reverse of the gid's address

                    #print("gid = %s gid' = %s\n" % (gid, (ngroups-gid-1)/ncontexts + 1))
                    lid = gid
                    migrate(lid,t,0,gid,nodeaddr[ (ngroups-gid-1)/ncontexts + 1 ],f)
                    t += 1

                # Now print out migrate keys
                #if lid > 0:
                    #f.write("lib.ContextJobApplication.timed_migrate =");
                    #for i in range(ngroups):
                        #f.write(' migrate{}'.format(i))

                    #f.write("\n")

                if lid > 0:
                    f.write("ServiceConfig.MicroBenchmark.MIGRATION_IDS = \"");
                    for i in range(ngroups):
                        if i > 0:
                            f.write(' ')
                        f.write('migrate{}'.format(i))

                    f.write("\"\n")

            elif param["MIGRATION_TYPE"] == "SCALE_OUT_AND_IN":
                # Read additional values
                t = int(param["MIGRATION_START_TIME"])
                lid = 0 # line_id

                # Scale out
                for gid in range(ngroups):
                    # move gid to whatever it has to go

                    #print("gid = %s gid' = %s\n" % (gid, (ngroups-gid-1)/ncontexts + 1))
                    lid = gid
                    if gid >= ncontexts:
                        migrate(lid,t,0,gid,nodeaddr[ gid/ncontexts + 1 ],f)
                    t += 1

                if lid > 0:
                    f.write("ServiceConfig.MicroBenchmark.MIGRATION_IDS = \"");
                    first = True
                    for i in range(ncontexts, ngroups):
                        if first:
                            first = False
                        else:
                            f.write(' ')
                        f.write('migrate{}'.format(i))

                    f.write("\"\n")

                # Scale in
                for gid in range(ngroups):
                    # move gid to 1'st node

                    #print("gid = %s gid' = %s\n" % (gid, (ngroups-gid-1)/ncontexts + 1))
                    lid = gid+ngroups
                    if gid >= ncontexts:
                        migrate(lid,t,0,gid,nodeaddr[ 1 ],f)
                    t += 1

                if lid > 0:
                    f.write("ServiceConfig.MicroBenchmark.MIGRATION_IDS2 = \"");
                    first = True
                    for i in range(ncontexts,ngroups):
                        if first:
                            first = False
                        else:
                            f.write(' ')
                        f.write('migrate{}'.format(i+ngroups))

                    f.write("\"\n")


            else:
                assert 0, "You must specify appropriate MIGRATION_TYPE!"
    
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
    parser.add_option("-o", "--output", dest="paramfile", action="store", type="string",
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
    if not options.paramfile:
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


    

