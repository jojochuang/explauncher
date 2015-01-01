#!/usr/bin/python2.7

from optparse import OptionParser
import logging
import random
import math

import Utils
import sys

logger = logging.getLogger('Benchmark.Configure')

class Configuration:

  def boot(self, line_id, time, ipaddr, port, host, app_type, f):
      f.write( '{} {:.3f} {}:{} {} {}\n'.format(
          line_id, 
          time, 
          ipaddr,
          port,
          host,
          app_type))
      return

  def migrate_multi(self, line_id, time, service_id, context_name, context_id, target_addr, from_sid, to_sid, f):
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
                  
  def migrate(self, line_id, time, service_id, context_name, context_id, target_addr, from_sid, to_sid, f):
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

  def loadHost(self  ):
      options = self.options
      param = self.param
      with open(options.host, "r") as h:
          for line in h:
              if self.param["EC2"] == "1":
                  ip = Utils.shell_exec("host %s | head -1 | awk '{print $4}'" % line.strip(), verbose=False)
              else:
                  ip = Utils.shell_exec("host %s | awk '{print $2}'" % line.strip(), verbose=False)
              self.hostname.append(line.strip())
              self.ipaddr.append(ip.strip())

      assert len(self.ipaddr) > 0, "Number of machines in host file should exist at least one"
      assert len(self.ipaddr) >= self.num_machines, "number of machines in host file is smaller than the machine we should use"
      return

                  
  def write_scale_out_in(self, f ):

      param = self.param
      service_name = param["server_service"]
      num_server_machines = self.num_server_machines
      # Put all the contexts in different node

      server_scale = int ( param["lib.MApplication.initial_size"] )
      # Building
      for i in range(self.num_contexts):
          if param["CONTEXT_ASSIGNMENT_POLICY"] == "NO_SHIFT":
            #sid = (0 + i % (num_server_machines) ) % self.num_machines
            sid = i % server_scale
          elif param["CONTEXT_ASSIGNMENT_POLICY"] == "SHIFT_BY_ONE":
            #sid = (0 + (i+1) % (num_server_machines) ) % self.num_machines
            sid = (i+1) % server_scale
          elif param["CONTEXT_ASSIGNMENT_POLICY"] == "RANDOM":
            #sid = (0 + random.randint(0, (num_server_machines) ) % (num_server_machines) ) % self.num_machines
            sid = random.randint(0, (server_scale-1) )
          else:
            print "Unrecognized parameter " . param["CONTEXT_ASSIGNMENT_POLICY"]
            sys.exit()

          f.write( 'lib.MApplication.{}.mapping = {}:Bucket[{}]\n'.format(
              service_name, sid, i))

      # Kids
      #for i in range(num_clients):
      #    sid = (1 + i % num_server_machines) % self.num_machines
      #    f.write( 'mapping = {}:Kid[{}]\n'.format(
      #        sid, i))
      #    f.write( 'lib.MApplication.{}.mapping = {}:Kid[{}]\n'.format(
      #        service_name, sid, i))

      # Also, add migration code
      return

  def write_scale_in_out(self,  f ):
      service_name = self.param["server_service"]
      # Put all the contexts in 1's node

      # Building
      for i in range(self.num_contexts):
          #f.write( 'mapping = {}:Building[{}]\n'.format(
          #    1, i))
          f.write( 'lib.MApplication.{}.mapping = {}:Bucket[{}]\n'.format(
              service_name, 1, i))

      # Kids
      #for i in range(num_clients):
      #    f.write( 'mapping = {}:Kid[{}]\n'.format(
      #        1, i))
      #    f.write( 'lib.MApplication.{}.mapping = {}:Kid[{}]\n'.format(
      #        service_name, 1, i))

      # Also, add migration code
      return

  def write_combined_migration(self,  f, serveraddr ):
      param = self.param
      service_name = param["server_service"]
      num_servers = self.num_servers
      # This would be the primary test that we will be using.
      # Set all the required values
      serveraddr = []

      # print nodeset
      i += 1

      # write for servers
      for j in range(num_servers):
          sid = (1 + j % num_server_machines) % self.num_machines
          serveraddr.append("%s:%s" % ( self.ipaddr[sid], options.port+i*self.port_shift) )
          i += 1


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
      for i in range(self.num_contexts):
          #f.write( 'mapping = {}:Building[{}]\n'.format(
          #    1, i))
          f.write( 'lib.MApplication.{}.mapping = {}:Bucket[{}]\n'.format(
              service_name, 1, i))

      # Kids
      #for i in range(num_clients):
      #    f.write( 'mapping = {}:Kid[{}]\n'.format(
      #        1, i))
      #    f.write( 'lib.MApplication.{}.mapping = {}:Kid[{}]\n'.format(
      #        service_name, 1, i))


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

          day_period = int(param["day_period"])
          num_days = int(param["num_days"])
          day_join = float(param["day_join"])
          day_leave = float(param["day_leave"])
          day_error = float(param["day_error"])
          sid = (1 + i % num_server_machines) % self.num_machines
          
          day_peak = (day_join + day_leave) / 2.0
          day_floor = (day_peak + 0.5) % 1

          day_floor = (day_join + day_leave) / 2.0
          day_floor = ( (day_join + day_leave) / 2.0 + 1 - 0.1 ) % 1   # Do it more eagerly
          day_peak = (day_floor + 0.5) % 1

          time_offset = (2 + d + day_floor) * day_period
          num_stages = int(math.ceil(math.log(num_servers, 2)))
          #print("num_stages = %d" % num_stages)
          num_migrations_ctx = num_stages * math.ceil(self.num_contexts / 2.0)
          time_diff_ctx = (0.5 / num_migrations_ctx) * day_period
          #time_diff_ctx = (0.5 / num_servers) * day_period
          num_migrations_cli = num_stages * math.ceil(self.num_clients / 2.0)
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
          for i in range(self.num_contexts):
              ctx_in_server[ i % num_servers ].append(i)

          for i in range(self.num_clients):
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
          f.write("lib.MApplication.timed_migrate =");
          for i in range(mid):
              f.write(' migrate{}'.format(i))

          f.write("\n")
      return

  def writeBoot( self ):
      # Write to output boot file (This is only for physical machines)
      num_processes = self.num_servers + self.num_clients
      options = self.options
      hostname = self.hostname
      with open(options.boot, "w") as f:
          # Write (id, time_to_boot, ip_addr, host_name)

          boot_period = 1.0 * options.setuptime / num_processes
          i=0  # id
          boot_time = 0

          if self.param["flavor"] == "nacho":
            # Write for head
            # the first few lines of boot file are for the bootstrapping nodes
            server_nodes = int( self.param["SERVER_LOGICAL_NODES"] )
            for j in range( server_nodes ):
              self.boot(i, boot_time, self.ipaddr[i % self.num_machines], options.port+i* self.port_shift, hostname[i%self.num_machines], "head", f) 
              i += 1
              boot_time += boot_period

            # Write for servers
            for j in range(self.num_servers - server_nodes):
                #sid = (1 + j % self.num_server_machines) % self.num_machines
                sid = (j % self.num_server_machines) % self.num_machines
                self.boot(i, boot_time, self.ipaddr[sid], options.port+i* self.port_shift, hostname[sid], "server", f) 
                i += 1
                boot_time += boot_period
          elif self.param["flavor"] == "context":
            # print servers followed by heads
            server_nodes = int( self.param["SERVER_LOGICAL_NODES"] )
            # Write for servers
            for j in range(self.num_servers - server_nodes):
                #sid = (1 + j % self.num_server_machines) % self.num_machines
                sid = (j % self.num_server_machines) % self.num_machines
                self.boot(i, boot_time, self.ipaddr[sid], options.port+i* self.port_shift, hostname[sid], "server", f) 
                i += 1
                boot_time += boot_period
            # Write for head
            # the first few lines of boot file are for the bootstrapping nodes
            for j in range( server_nodes ):
              self.boot(i, boot_time, self.ipaddr[i % self.num_machines], options.port+i* self.port_shift, hostname[i%self.num_machines], "head", f) 
              i += 1
              boot_time += boot_period


          # Write for clients
          for j in range(self.num_clients):
              sid = ( self.num_server_machines + j % self.num_client_machines) % self.num_machines
              self.boot(i, boot_time, self.ipaddr[sid], options.port+i* self.port_shift, hostname[sid], "client", f) 
              i += 1
              boot_time += boot_period
      return

  def writeHost( self  ):

      # Write to output host file
      hostname_set = set( self.hostname ) # create unique host name

      if len( hostname_set ) != len( self.hostname ): # check to make sure all host names are unique
        sys.exit()

      with open(options.hostrun, "w") as f:
          with open(options.hostnohead, "w") as g:
              for h in hostname_set: 
                  f.write("%s\n" % h )
                  if h != self.hostname[0]:
                      g.write("%s\n" % h)
      return

  def writeServerConfig( self, index ):
      options = self.options
      param = self.param
      # Write to output server conf file
      # read the hosts file to get the "head" of the server address

      # do I write to multiple param files?
      #param_file_name = options.paramfile + str(index)
      param_file_name = options.paramfile 
      with open(param_file_name, "a") as f:
          # TODO: write lib.MApplication.nodeset
          if param["flavor"] == "nacho":
            f.write("lib.MApplication.bootstrapper = IPV4/{}:{}\n".format( self.hostname[index], options.port+ index* self.port_shift ) );
          elif param["flavor"] == "context":
            for j in range(self.num_servers):
              f.write( "lib.MApplication.nodeset = IPV4/{host}:{port}\n".format( host= self.hostname[j ], port=options.port+j*self.port_shift ));

          f.write( '' );

          # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
          if param["EC2"] == "1":
              f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -f | awk '{print $1}'", verbose=False)))
          else:
              f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

          # WC: don't know the use of these two parameters
          # write down HEAD_IPADDR, which is the first node in the hosts file
          #f.write( "HEAD_IPADDR = %s\n" % self.ipaddr[0] )
          #f.write( "SERVER_ADDR = %s:%s\n" % (self.ipaddr[0], options.port) )


          # Now, print initial mapping due to migration policy.
          if param["EXPERIMENT_TYPE"] == "SCALE_OUT_AND_IN":
              self.write_scale_out_in( f )
      
          elif param["EXPERIMENT_TYPE"] == "SCALE_IN_AND_OUT":
              self.write_scale_in_out( f )

          elif param["EXPERIMENT_TYPE"] == "COMBINED":
              self.write_combined_migration( f, serveraddr )

          else:
              assert 0, "Please specify EXPERIMENT_TYPE!"

      return

  def writeClientConfig( self ):
      num_clients = self.num_clients 
      param = self.param
      day_period = self.day_period
      # Write to output client conf file
      with open(options.clientfile, "a") as f:
          if param["flavor"] == "nacho":
              for j in range(self.num_servers):
                f.write( "LAUNCHER.receiver_addr = IPV4/{host}:{port}\n".format( host= self.hostname[j ], port=options.port+j*self.port_shift ));
          elif param["flavor"] == "context":
            server_nodes = int( self.param["SERVER_LOGICAL_NODES"] )
            for j in range(server_nodes):
              f.write( "LAUNCHER.receiver_addr = IPV4/{host}:{port}\n".format( host= self.hostname[j ], port=options.port+j*self.port_shift ));
            for j in range(num_clients):
              f.write( "lib.MApplication.nodeset = IPV4/{host}:{port}\n".format( host= self.hostname[j+ self.num_servers ], port=options.port+(j+self.num_servers)*self.port_shift ));
          elif param["flavor"] == "mace":
              raise Exception( "mace flavor not supported" )
          f.write( "lib.MApplication.{service_name}.mapping = 0:ABC\n".format( 
            service_name = param["client_service"] ));
          f.write( "ServiceConfig.KeyValueClient.DHT_NODES = IPV4/{host}:{port}\n".format( host= self.hostname[0 ], port=options.port ));


          # write down hostname0, which is the experiment initiator. (it may not be in hosts file)
          f.write( "hostname0 = %s\n" % (Utils.shell_exec("hostname -s | awk '{print $1}'", verbose=False)))

          # write down HEAD_IPADDR, which is the first node in the hosts file
          f.write( "HEAD_IPADDR = %s\n" % self.ipaddr[0] )
          f.write( "SERVER_ADDR = %s:%s\n" % (self.ipaddr[0], options.port) )
          
          # print client JOIN_TIME and LEAVE_TIME
          # Just choose from random

          # Initialize random
          rnd = random.Random()
          rnd.seed(0)

          i = 1 + self.num_servers # id

          if param["JOIN_TYPE"] == "FLAT":

              for j in range(num_clients):
                  f.write('JOIN_TIME_{} = {}\n'.format(
                      i,
                      int(self.day_join * day_period)))
                  f.write('LEAVE_TIME_{} = {}\n'.format(
                      i,
                      int(self.day_leave * day_period)))
                  i += 1
          elif param["JOIN_TYPE"] == "INVERSE_FLAT":

              for j in range(num_clients):
                  f.write('JOIN_TIME_{} = {}\n'.format(
                      i,
                      int(self.day_leave * day_period)))
                  f.write('LEAVE_TIME_{} = {}\n'.format(
                      i,
                      int(self.day_join * day_period)))
                  i += 1
          elif param["JOIN_TYPE"] == "RANDOM":

              for j in range(num_clients):
                  join_time = int(rnd.gauss(self.day_join,day_error) * day_period % day_period)
                  leave_time = int(rnd.gauss(self.day_leave,day_error) * day_period % day_period)
                  while join_time < 0:
                      join_time += day_period
                  while leave_time < 0:
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
                      int(rnd.gauss(self.day_join,day_error) * day_period) % day_period))
                  f.write('LEAVE_TIME_{} = {}\n'.format(
                      i,
                      int(rnd.gauss(self.day_leave,day_error) * day_period) % day_period))
                  i += 1

          elif param["JOIN_TYPE"] == "ROUND":

              for j in range(num_clients):
                  mid_time = int(rnd.gauss( (self.day_join+self.day_leave)/2, day_error) * day_period % day_period)
                  while mid_time < 0:
                      mid_time += day_period
                  period = rnd.gauss( 0.2, day_error) * day_period
                  while period < 0:
                      period += day_period
                  join_time = int((mid_time - period) % day_period)
                  leave_time = int((mid_time + period) % day_period)

                  while join_time < 0:
                      join_time += day_period
                  while leave_time < 0:
                      leave_time += day_period

                  assert join_time >=0 and join_time < day_period
                  assert leave_time >=0 and leave_time < day_period


                  f.write('JOIN_TIME_{} = {}\n'.format(
                      i,join_time))
                  f.write('LEAVE_TIME_{} = {}\n'.format(
                      i,leave_time))
                  i += 1
          else:
              assert 0, "Please specify JOIN_TYPE"

      return

  def __init__(self, options):
      """
      Main module of configure-microbenchmark.
      """

      self.options = options
      # Read param file before append
      self.param = Utils.param_reader(options.paramfile)

      # Read host file
      self.ipaddr = []
      self.hostname = []

      self.port_shift = int(self.param["port_shift"])
      self.num_machines = int(self.param["num_machines"])
      self.num_servers = int(self.param["num_servers"])
      self.num_clients = int(self.param["num_clients"])
      self.num_server_machines = int(self.param["num_server_machines"])
      self.num_client_machines = int(self.param["num_client_machines"])
      self.num_contexts = int(self.param["num_contexts"])
      
      self.day_period = int(self.param["day_period"])
      self.num_days = int(self.param["num_days"])
      self.day_join = float(self.param["day_join"])
      self.day_leave = float(self.param["day_leave"])
      self.day_error = float(self.param["day_error"])
      
      assert self.num_machines == self.num_server_machines + self.num_client_machines
      assert self.num_machines > 0
      assert self.num_servers >= self.num_server_machines # number of server process is larger than the number of server machines
      assert self.num_clients >= self.num_client_machines
      assert self.port_shift > 0

      self.loadHost( )

      self.writeBoot( )

      self.writeHost( )

      for i in range( int( self.param["SERVER_LOGICAL_NODES"] ) ):
        self.writeServerConfig( i )

      self.writeClientConfig(  )

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

    config = Configuration( options )

    #main(options)

    main_end_time = Utils.unixTime()

    #logger.info("Total time : %f sec", main_end_time - main_start_time)


    

