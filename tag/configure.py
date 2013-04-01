#!/usr/bin/python2.7

from optparse import OptionParser
import logging
import random
import math

import Utils



logger = logging.getLogger('Benchmark.Configure')

def boot(line_id, time, ipaddr, port, host, app_type, f):
    f.write( '{} {:.3f} {}:{} {} {}\n'.format(
        line_id, 
        time, 
        ipaddr,
        port,
        host,
        app_type))
    return

def migrate_multi(line_id, time, service_id, context_name, context_id, target_addr, from_sid, to_sid, f):
    f.write('#{} - from {} to {} what {}[{}]\n'.format(
        line_id,
        from_sid,
        to_sid,
        context_name,
        context_id))
    f.write('migrate{}.time = {}\n'.format(
        line_id,
        int(time)))
    f.write('migrate{}.service = {}\n'.format(
        line_id,
        service_id))
    f.write('migrate{}.dest = {}\n'.format(
        line_id,
        target_addr))
    clist = []
    for c in context_id:
        clist.append( "%s[%s]" % (context_name, c) )

    f.write('migrate{}.contexts = {}\n'.format(
        line_id,
        ' '.join(clist)))
    f.write('\n')
    return
                
def migrate(line_id, time, service_id, context_name, context_id, target_addr, from_sid, to_sid, f):
    f.write('#{} - from {} to {} what {}[{}]\n'.format(
        line_id,
        from_sid,
        to_sid,
        context_name,
        context_id))
    f.write('migrate{}.time = {}\n'.format(
        line_id,
        int(time)))
    f.write('migrate{}.service = {}\n'.format(
        line_id,
        service_id))
    f.write('migrate{}.dest = {}\n'.format(
        line_id,
        target_addr))
    f.write('migrate{}.contexts = {}[{}]\n'.format(
        line_id,
        context_name,
        context_id))
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

    service_name = param["server_service"]
    num_machines = int(param["num_machines"])
    num_servers = int(param["num_servers"])
    num_clients = int(param["num_clients"])
    num_server_machines = int(param["num_server_machines"])
    num_client_machines = int(param["num_client_machines"])

    num_contexts = int(param["num_contexts"])
    
    num_processes = 1 + num_servers + num_clients

    day_period = int(param["day_period"])
    num_days = int(param["num_days"])
    day_join = float(param["day_join"])
    day_leave = float(param["day_leave"])
    day_error = float(param["day_error"])
    

    assert num_machines == num_server_machines + num_client_machines + 1
    assert num_machines > 0
    assert num_servers >= num_server_machines
    assert num_clients >= num_client_machines


    with open(options.host, "r") as h:
        for line in h:
            ip = Utils.shell_exec("host %s | awk '{print $2}'" % line.strip(), verbose=False)
            #print("host = %s, ip = %s" % (line.strip(), ip.strip()))
            hostname.append(line.strip())
            ipaddr.append(ip.strip())

    assert len(ipaddr) > 0, "Number of machines in host file should exist at least one"
    assert len(ipaddr) >= num_machines, "number of machines in host file is smaller than the machine we should use"

    # Write to output boot file (This is only for physical machines)
    with open(options.boot, "w") as f:
        # Write (id, time_to_boot, ip_addr, host_name)

        boot_period = 1.0 * options.setuptime / num_processes
        i=0  # id
        boot_time = 0

        # Write for head
        boot(i, boot_time, ipaddr[i % num_machines], options.port+i*2, hostname[i%num_machines], "head", f) 
        i += 1
        boot_time += boot_period

        # Write for servers
        for j in range(num_servers):
            sid = (1 + j % num_server_machines) % num_machines
            boot(i, boot_time, ipaddr[sid], options.port+i*2, hostname[sid], "server", f) 
            i += 1
            boot_time += boot_period

        # Write for clients
        for j in range(num_clients):
            sid = (1 + num_server_machines + j % num_client_machines) % num_machines
            boot(i, boot_time, ipaddr[sid], options.port+i*2, hostname[sid], "client", f) 
            i += 1
            boot_time += boot_period

    # Write to output host file
    with open(options.hostrun, "w") as f:
        with open(options.hostnohead, "w") as g:
            for i in range(num_machines):
                f.write("%s\n" % hostname[i])
                if i > 0:
                    g.write("%s\n" % hostname[i])

    # Write to output server conf file
    with open(options.paramfile, "a") as f:
        serveraddr = []

        # print nodeset
        i=0  # id

        # write for head
        f.write( 'nodeset = {}:{}\n'.format(
            ipaddr[i], options.port+i*2))
        f.write( 'lib.ContextJobApplication.nodeset = IPV4/{}:{}\n'.format(
            ipaddr[i], options.port+i*2))

        i += 1

        # write for servers
        for j in range(num_servers):
            sid = (1 + j % num_server_machines) % num_machines
            f.write( 'nodeset = {}:{}\n'.format(
                ipaddr[sid], options.port+i*2))
            f.write( 'lib.ContextJobApplication.nodeset = IPV4/{}:{}\n'.format(
                ipaddr[sid], options.port+i*2))
            serveraddr.append("%s:%s" % ( ipaddr[sid], options.port+i*2) )
            i += 1

        # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
        f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

        # write down HEAD_IPADDR, which is the first node in the hosts file
        f.write( "HEAD_IPADDR = %s\n" % ipaddr[0] )
        f.write( "SERVER_ADDR = %s:%s\n" % (ipaddr[0], options.port) )


        # Now, print initial mapping due to migration policy.
        if param["EXPERIMENT_TYPE"] == "SCALE_OUT_AND_IN":
            # Put all the contexts in different node

            # Building
            for i in range(num_contexts):
                sid = (1 + i % num_server_machines) % num_machines
                f.write( 'mapping = {}:Building[{}]\n'.format(
                    sid, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Building[{}]\n'.format(
                    service_name, sid, i))

            # Kids
            for i in range(num_clients):
                sid = (1 + i % num_server_machines) % num_machines
                f.write( 'mapping = {}:Kid[{}]\n'.format(
                    sid, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Kid[{}]\n'.format(
                    service_name, sid, i))

            # Also, add migration code
    
        elif param["EXPERIMENT_TYPE"] == "SCALE_IN_AND_OUT":
            # Put all the contexts in 1's node

            # Building
            for i in range(num_contexts):
                f.write( 'mapping = {}:Building[{}]\n'.format(
                    1, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Building[{}]\n'.format(
                    service_name, 1, i))

            # Kids
            for i in range(num_clients):
                f.write( 'mapping = {}:Kid[{}]\n'.format(
                    1, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Kid[{}]\n'.format(
                    service_name, 1, i))

            # Also, add migration code

        elif param["EXPERIMENT_TYPE"] == "COMBINED":
            # This would be the primary test that we will be using.
            # Set all the required values

            initial_no_migration_days = int(param["INITIAL_NO_MIGRATION_DAYS"])
            final_no_migration_days = int(param["FINAL_NO_MIGRATION_DAYS"])
            assert initial_no_migration_days >= 0 and initial_no_migration_days <= num_days
            assert final_no_migration_days >= 0 and final_no_migration_days <= num_days
            migration_days = num_days - initial_no_migration_days - final_no_migration_days

            assert num_days > 0
            assert migration_days >= 0

            #assert join_time < leave_time

            
            # 1. All contexts start in one context.

            # Building
            for i in range(num_contexts):
                f.write( 'mapping = {}:Building[{}]\n'.format(
                    1, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Building[{}]\n'.format(
                    service_name, 1, i))

            # Kids
            for i in range(num_clients):
                f.write( 'mapping = {}:Kid[{}]\n'.format(
                    1, i))
                f.write( 'lib.ContextJobApplication.{}.mapping = {}:Kid[{}]\n'.format(
                    service_name, 1, i))


            # 2. Plan out migration for migration_days
            #    If you set migration starts from day 2,
            #    Note that you should start migration day before that.

            """
                1 day = 1.0
                day_join at 0.2 (day_join)
                day_leave at 0.5 (day_leave)
                peak at 0.35
                low at 0.85

                If you have six days, it will be
                0.2 (h) -> 0.5 (l) -> 1.2 (h) -> 1.5 (l) -> ...
                ... 5.2 (h) -> 5.5(l) -> 6.0(x)

                So, [ 0.0 -> 0.5 ] is first day
                    [ 0.5 -> 1.5 ] is second day
                    [ 1.5 -> 2.5 ] is third day
                    [ 2.5 -> 3.5 ] is fourth day
                    [ 3.5 -> 4.5 ] is firth day
                    [ 4.5 -> 5.5 ] is sixth day
                    [ 5.5 -> 6.0 ] is seventh day

                In this case, you will do only migrate for
                    [ 2.5 -> 3.5 ] is fourth day
                        2.5 -> 3.2 : scale out
                        3.2 -> 3.5 : scale in
                    [ 3.5 -> 4.5 ] is firth day
                    

            """
            mid = 0  # Generic migration id
            ncurserver = 1

            f.write("# num_servers 0 %s\n" % ncurserver)

            for d in range(initial_no_migration_days, initial_no_migration_days + migration_days):

                #day_period = int(param["day_period"])
                #num_days = int(param["num_days"])
                #day_join = float(param["day_join"])
                #day_leave = float(param["day_leave"])
                #day_error = float(param["day_error"])
                #sid = (1 + i % num_server_machines) % num_machines
                
                #day_peak = (day_join + day_leave) / 2.0
                #day_floor = (day_peak + 0.5) % 1

                #day_floor = (day_join + day_leave) / 2.0
                day_floor = ( (day_join + day_leave) / 2.0 + 1 - 0.1 ) % 1   # Do it more eagerly
                day_peak = (day_floor + 0.5) % 1

                time_offset = (2 + d + day_floor) * day_period
                num_stages = int(math.ceil(math.log(num_servers, 2)))
                #print("num_stages = %d" % num_stages)
                num_migrations_ctx = num_stages * math.ceil(num_contexts / 2.0)
                time_diff_ctx = (0.5 / num_migrations_ctx) * day_period
                #time_diff_ctx = (0.5 / num_servers) * day_period
                num_migrations_cli = num_stages * math.ceil(num_clients / 2.0)
                time_diff_cli = (0.5 / num_migrations_cli) * day_period
                #time_diff_cli = (0.5 / num_servers) * day_period
                


                # A. Gradual scale out
                """
                    Each migration will have "stages".
                    If you have total 8 nodes, then you will have 3 stages.
                    For each state, one node will send half of their contents out to counterpart.
                    
                    e.g.
                        0 has [0 1 2 3 4 5 6 7]

                        1st stage (for 4 second)
                            0 sends [1 3 5 7] to 1
                        2nd stage (for 4 second)
                            0 sends [2 6] to 2
                            1 sends [3 7] to 3
                        3rd stage (for 4 second)
                            0 sends [4] to 4
                            1 sends [5] to 5
                            2 sends [6] to 6
                            3 sends [7] to 7
                        
                        Also, each number has (contexts/server) number of contexts.

                        For each stage, each node will send even numbered contexts to the node that has same id of first even number.
                """

                f.write("\n# Starting gradual scale out\n")

                t1 = time_offset
                t2 = time_offset

                # create ctx_in_server
                ctx_in_server = []
                cli_in_server = []
                servers = []
                for i in range(num_servers):
                    ctx_in_server.append([])
                    cli_in_server.append([])
                    servers.append([])

                # insert each contexts in appropriate server.
                for i in range(num_contexts):
                    ctx_in_server[ i % num_servers ].append(i)

                for i in range(num_clients):
                    cli_in_server[ i % num_servers ].append(i)

                # initiallly, server[0] has all
                # servers[0] = [0 1 2 3 4 5 6 7]
                for i in range(num_servers):
                    servers[0].append(i)

                for s in range(num_stages):
                    for i in range(pow(2,s)):
                        assert i < num_servers

                        # Get half of it to migrate to other node.
                        moving_servers = servers[i][1::2]
                        # Rest of half will remain.
                        servers[i] = servers[i][::2]

                        if len(moving_servers) > 0:
                            target_sid = moving_servers[0]
                            servers[target_sid] = moving_servers

                            # Migrate all contexts within the server
                            # Also, migrate clients as well

                            # Once for all
                            contexts = []
                            clis = []
                            for ctxs in moving_servers:
                                contexts.extend(ctx_in_server[ctxs])
                                clis.extend(cli_in_server[ctxs])


                            f.write("# num_servers %d %s\n" % (t1-1, ncurserver))
                            ncurserver += 1
                            f.write("# num_servers %d %s\n" % (t1, ncurserver))

                            #migrate_multi( mid, t1, 0, "Building", contexts, serveraddr[target_sid], i, target_sid,  f)
                            #mid += 1
                            ##t1 += time_diff_ctx * len(contexts)
                            #t1 += time_diff_ctx * len(contexts) * 0.4  # adjusted

                            migrate_multi( mid, t2, 0, "Kid", clis, serveraddr[target_sid], i, target_sid, f)
                            mid += 1
                            #t2 += time_diff_cli * len(clis)
                            t2 += time_diff_cli * len(clis) * 0.4  # adjusted

                            # One at a time
                            #for ctxs in moving_servers:
                                #for c in ctx_in_server[ctxs]:
                                    #migrate( mid, t1, 0, "Building", c, serveraddr[target_sid], i, target_sid, f)
                                    #mid += 1
                                    #t1 += time_diff_ctx

                                #for c in cli_in_server[ctxs]:
                                    #migrate( mid, t2, 0, "Kid", c, serveraddr[target_sid], i, target_sid, f)
                                    #mid += 1
                                    #t2 += time_diff_cli

                # B. Gradual scale in
                """
                    Each migration will have "stages".
                    If you have total 8 nodes, then you will have 3 stages.
                    For each state, a node will send their all contents to their (server_id%numservers_at_stage)'s server.
                    
                    e.g.
                        there are [0] [1] [2] [3] [4] [5] [6] [7]

                        1st stage (for 4 second)
                            4 sends [4] to 0
                            5 sends [5] to 1
                            6 sends [6] to 2
                            7 sends [7] to 3
                        2nd stage (for 4 second)
                            2 sends [2 6] to 0
                            3 sends [3 7] to 1
                        3rd stage (for 4 second)
                            1 sends [1 3 5 7] to 0
                        
                        Also, each number has (contexts/server) number of contexts.

                        For each stage, each node will send even numbered contexts to the node that has same id of first even number.
                """

                f.write("\n# Starting gradual scale in\n")

                # Gradual scale in
                t1 = time_offset + 0.5 * day_period + 0.15 * day_period
                t2 = time_offset + 0.5 * day_period + 0.15 * day_period

                servers = []
                for i in range(num_servers):
                    servers.append([])

                for i in range(num_servers):
                    servers[i].append(i)

                for s in range(num_stages,0,-1):
                    numservers_at_stage = pow(2,s-1)
                    for i in range(numservers_at_stage,2*numservers_at_stage):
                        assert i < num_servers

                        # move all servers to (server_id % numservers_at_stage)
                        moving_servers = servers[i]

                        if len(moving_servers) > 0:
                            target_sid = i % numservers_at_stage
                            servers[target_sid].extend( moving_servers )

                            # Migrate all contexts within the server
                            # Also, migrate clients as well

                            # Once for all
                            contexts = []
                            clis = []
                            for ctxs in moving_servers:
                                contexts.extend(ctx_in_server[ctxs])
                                clis.extend(cli_in_server[ctxs])

                            f.write("# num_servers %d %s\n" % (t1-1, ncurserver))
                            ncurserver -= 1
                            f.write("# num_servers %d %s\n" % (t1, ncurserver))

                            #migrate_multi( mid, t1, 0, "Building", contexts, serveraddr[target_sid], i, target_sid,  f)
                            #mid += 1
                            ##t1 += time_diff_ctx + len(contexts)
                            #t1 += time_diff_ctx * len(contexts) * 0.4  # adjusted

                            migrate_multi( mid, t2, 0, "Kid", clis, serveraddr[target_sid], i, target_sid, f)
                            mid += 1
                            #t2 += time_diff_cli + len(clis)
                            t2 += time_diff_cli * len(clis) * 0.4  # adjusted

                            # One at a time
                            #for ctxs in moving_servers:
                                #for c in ctx_in_server[ctxs]:
                                    #migrate( mid, t1, 0, "Building", c, serveraddr[target_sid], i, target_sid, f)
                                    #mid += 1
                                    #t1 += time_diff_ctx

                                #for c in cli_in_server[ctxs]:
                                    #migrate( mid, t2, 0, "Kid", c, serveraddr[target_sid], i, target_sid, f)
                                    #mid += 1
                                    #t2 += time_diff_cli


                f.write("# num_servers %d %s\n" % (t1-1, ncurserver))
                ncurserver = 1
                f.write("# num_servers %d %s\n" % (t1, ncurserver))

            # 3. Finally, activate all migration ids
            if mid > 0:
                f.write("lib.ContextJobApplication.timed_migrate =");
                for i in range(mid):
                    f.write(' migrate{}'.format(i))

                f.write("\n")


        else:
            assert 0, "Please specify EXPERIMENT_TYPE!"



    

    # Write to output client conf file
    with open(options.clientfile, "a") as f:
        # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
        f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

        # write down HEAD_IPADDR, which is the first node in the hosts file
        f.write( "HEAD_IPADDR = %s\n" % ipaddr[0] )
        f.write( "SERVER_ADDR = %s:%s\n" % (ipaddr[0], options.port) )
        
        # print client JOIN_TIME and LEAVE_TIME
        # Just choose from random

        # Initialize random
        rnd = random.Random()
        rnd.seed(0)

        i = 1 + num_servers # id

        if param["JOIN_TYPE"] == "FLAT":

            for j in range(num_clients):
                f.write('JOIN_TIME_{} = {}\n'.format(
                    i,
                    int(day_join * day_period)))
                f.write('LEAVE_TIME_{} = {}\n'.format(
                    i,
                    int(day_leave * day_period)))
                i += 1
        elif param["JOIN_TYPE"] == "INVERSE_FLAT":

            for j in range(num_clients):
                f.write('JOIN_TIME_{} = {}\n'.format(
                    i,
                    int(day_leave * day_period)))
                f.write('LEAVE_TIME_{} = {}\n'.format(
                    i,
                    int(day_join * day_period)))
                i += 1
        elif param["JOIN_TYPE"] == "RANDOM":

            for j in range(num_clients):
                join_time = int(rnd.gauss(day_join,day_error) * day_period % day_period)
                leave_time = int(rnd.gauss(day_leave,day_error) * day_period % day_period)
                if join_time < 0:
                    join_time += day_period
                if leave_time < 0:
                    leave_time += day_period

                assert join_time >=0 and join_time < day_period
                assert leave_time >=0 and leave_time < day_period

                f.write('JOIN_TIME_{} = {}\n'.format(
                    i,join_time))
                f.write('LEAVE_TIME_{} = {}\n'.format(
                    i,leave_time))
                i += 1

        elif param["JOIN_TYPE"] == "GAUSS":

            for j in range(num_clients):
                f.write('JOIN_TIME_{} = {}\n'.format(
                    i,
                    int(rnd.gauss(day_join,day_error) * day_period) % day_period))
                f.write('LEAVE_TIME_{} = {}\n'.format(
                    i,
                    int(rnd.gauss(day_leave,day_error) * day_period) % day_period))
                i += 1
        else:
            assert 0, "Please specify JOIN_TYPE"

    return


###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Microbenchmark configure file generator.")

    parser.add_option("-a", "--application", dest="app", action="store", type="string",
    help="Name of the application. e.g. microbenchmark.")
    parser.add_option("-f", "--flavor", dest="flavor", action="store", type="string",
    help="Type of the application. e.g. context.")
    parser.add_option("-p", "--port", dest="port", action="store", type="int",
    help="Mace starting port.")
    parser.add_option("-o", "--output", dest="paramfile", action="store", type="string",
    help="Output server .conf file to append.")
    parser.add_option("-c", "--client", dest="clientfile", action="store", type="string",
    help="Output client .conf file to append.")
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
    if not options.port:
        parser.error("Missing --port")
    if not options.paramfile:
        parser.error("Missing --output")
    if not options.clientfile:
        parser.error("Missing --client")
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


    

