#!/usr/bin/perl -w

use strict;
use Getopt::Long;
#use Math;

require "conf/config.pl";

unless (@ARGV) {
    print "usage: $0\n";
    #print "  -m (rsync maceclean-project)\n";
    #print "  -f (rsync mace-project)\n";
    print "  -b (rsync benchmark)\n";

    print "  -r (regenerate conf/hosts from conf/instance)\n";
    print "  -p (do parallel ssh for pwd)\n";
    #print "  -t (terminate all running instances) [ unimplemented ]\n";
    print "  -a [CREATE ADD START STOP TERMINATE] instances\n";

    #print "  -s (sync machine lists)\n";
    print "  -i (create new ami image)\n";
    print "  -d (instance name to delete)\n";

}

# get the list of active nodes except the local host
# ec2din |grep INSTANCE |awk '$4 !~ "stopped" {print $5}'| grep -v `hostname`

#my $mace_rsync = 0;
my $fullcontext_rsync = 0;
my $benchmark_rsync = 0;
my $pssh = 0;
my $action = "";
my $regenerate = 0;
my $num_instances = 0;
#my $sync = 0;
my $image_create = 0;
my $delete = "";
my $instance_type = "m1.medium";

GetOptions(#"mace_rsync" => \$mace_rsync,
    #"fullcontext_rsync" => \$fullcontext_rsync,
           "benchmark_rsync" => \$benchmark_rsync,
           "regenerate" => \$regenerate,
           "pssh" => \$pssh,
           "action=s" => \$action,
           #"sync" => \$sync,
           "image_create" => \$image_create,
           "delete=s" => \$delete,
           "num_instances=i" => \$num_instances,
       );


my $ec2_key = get_ec2key();
my $ec2_pass = get_ec2pass();
my $ec2_instance = get_ec2instance();
my $key_pair_name = get_keypairname();
#sed -i".bak" '/ecdsa/d' known_hosts

# Create new AMI image
if( $image_create ) {
    my $ami_name_old = trim(`cat conf/ami-id | awk '{print \$1}'`);
    my $ami_name_new = $ami_name_old+1;
    my $run = "ec2-create-image -O ${ec2_key} -W ${ec2_pass} ${ec2_instance} -name nacho-${ami_name_new} --no-reboot | awk '{print \$2}'";
    # TODO: add description of the nacho runtime and explauncher
    print "\$ ${run}\n";
    my $out = trim(`$run`);
    print "${out}\n";

    open(OUT, ">conf/ami-id") or die "cannot open conf/ami-id for output";
    print OUT "${ami_name_new} ${out}";
    close(OUT);
}

my $ami_id = trim(`cat conf/ami-id | awk '{print \$2}'`);

# Terminate instances
if( $action eq "TERMINATE" ) {
    my $run = "cat conf/instance | paste -sd \" \" | xargs ec2-terminate-instances -O ${ec2_key} -W ${ec2_pass}";
    print "\$ ${run}\n";
    print `$run`;


    # Flush the instance-list.txt as well..
}

if( $action eq "STOP" ) {
    my $run = "cat conf/instance | paste -sd \" \" | xargs ec2-stop-instances -O ${ec2_key} -W ${ec2_pass}";
    print "\$ ${run}\n";
    print `$run`;
}

if( $action eq "START" ) {
    my $run = "cat conf/instance | paste -sd \" \" | xargs ec2-start-instances -O ${ec2_key} -W ${ec2_pass}";
    if( $num_instances > 0 ){
        $run = "cat conf/instance |head -n $num_instances | paste -sd \" \" | xargs ec2-start-instances -O ${ec2_key} -W ${ec2_pass}";
    }
    print "\$ ${run}\n";
    print `$run`;
}

# Create instances
if( $action eq "CREATE" ) {
    my $param_security_group="";
    my $secgroup = get_securitygroup();
    if ( $secgroup ne "" ){
        $param_security_group="-g $secgroup"
    }
    my $run = "ec2-run-instances -O ${ec2_key} -W ${ec2_pass} ${ami_id} -n ${num_instances} -k $key_pair_name -t $instance_type --availability-zone us-east-1a $param_security_group| grep INSTANCE | awk '{print \$2}'";
    print "\$ ${run}\n";

    open STDERR, ">&STDOUT" or die( "can't redirect STDERR");
    my @instances = `$run`;
    my $instances_list = join(" ", map { trim($_) } @instances); 

    print "Created instances : ${instances_list}\n";

    # print instance-list.txt
    open(OUT, ">conf/instance") or die "cannot open conf/instance for output";
    print OUT join("\n", map { trim($_) } @instances)."\n";
    close(OUT);

}

if( $action eq "ADD" ) {
    my $param_security_group="";
    my $secgroup = get_securitygroup();
    if ( $secgroup ne "" ){
        $param_security_group="-g $secgroup"
    }
    my $run = "ec2-run-instances -O ${ec2_key} -W ${ec2_pass} ${ami_id} -n ${num_instances} -k $key_pair_name -t $instance_type $param_security_group| grep INSTANCE | awk '{print \$2}'";
    print "\$ ${run}\n";

    open STDERR, ">&STDOUT" or die( "can't redirect STDERR");
    my @instances = `$run`;
    my $instances_list = join(" ", map { trim($_) } @instances); 

    print "Added instances : ${instances_list}\n";

    # print instance-list.txt
    open(OUT, ">>conf/instance") or die "cannot open conf/instance for output";
    print OUT join("\n", map { trim($_) } @instances)."\n";
    close(OUT);

}

if( $delete ne "" ) {
    my $run = "ec2-terminate-instances -O ${ec2_key} -W ${ec2_pass} ${delete}";
    print "\$ ${run}\n";
    print `$run`;

    $run = "sed -i\".bak\" '/${delete}/d' conf/instance";
    #my $run = "cat instance-list.txt | paste -sd \" \" | xargs ec2-start-instances -O ${ec2_key} -W ${ec2_pass}";
    print "\$ ${run}\n";
    print `$run`;
}

# Generate conf/hosts
if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" || $delete || $regenerate )
{
    if( $action eq "CREATE" || $action eq "ADD" ) {
        sleep(30);
    }
    open(FILE, "conf/instance") or die "cannot open conf/instance for read";
    my @instances = <FILE>;
    my @some_instances = ();
    if( $num_instances == 0 ){
        @some_instances = @instances;
    }else{
        @some_instances = @instances[ 0 .. ($num_instances-1) ];
    }
    my $instances_list = join(" ", map { trim($_) } @some_instances); 
    close FILE;

    print "Listed instances : ${instances_list}\n";

    #my $run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$4}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    my $run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$5}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    print "\$ ${run}\n";

    my @hosts = `$run`;
    open(OUT, ">conf/hosts") or die "cannot open conf/hosts for output";
    print OUT join("\n", map { trim($_) } @hosts)."\n";
    print "Hosts : ".join(" ", map { trim($_) } @hosts)."\n";
    close(OUT);
}

open(FILE, "conf/hosts") or die("Unable to read conf/hosts\n");
my @hosts = <FILE>;
close FILE;

if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" || $pssh ) {
    if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" ) {
        sleep(30);
    }
    my @childs;
    foreach(@hosts) {
        my $pid = fork();
        if( $pid) {
            # parent
            push(@childs,$pid);
        } elsif( $pid == 0 ) {
            # child
            subexecute("ssh", $_, "pwd");
            exit 0;
        } else {
            die "couldn't fork: $!\n";
        }
    }

    foreach(@childs) {
        my $tmp = waitpid($_, 0);
        #print "Done with pid $tmp\n";
    }
}

#if( $mace_rsync ) {
#    print "\$ cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/maceclean-project/ {}:~/maceclean-project\n";
#    print `cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/maceclean-project/ {}:~/maceclean-project`
#}
#
#if( $fullcontext_rsync) {
#    print "\$ cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/mace-project/ {}:~/mace-project\n";
#    print `cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/mace-project/ {}:~/mace-project`
#}

if( $benchmark_rsync) {
    print "\$ cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/benchmark/ {}:~/benchmark\n";
    print `cat conf/hosts | xargs --max-lines=1 -I {} rsync -vauz ~/benchmark/ {}:~/benchmark`
}

print "\$ cp conf/hosts ../microbenchmark/conf/hosts\n";
print `cp conf/hosts ../microbenchmark/conf/hosts`;

sub subexecute {
    my $cmd = shift;
    my $host = trim(shift);
    my $rcmd = shift;

EXEC:
    my $exec = qq{sh -c "$cmd $host $rcmd 2>&1"};

    open STDERR, ">&STDOUT" or die( "can't redirect STDERR");
    my @result = `$exec`;

    for my $l (@result) {
        chomp $l;
        print $host." ".$l."\n";
        # Offending key for IP in /home/ubuntu/.ssh/known_hosts:596
        if ($l =~ m~^Offending[^\:]+\:(\d+)~) {
            my $ssh_line = $1;
            print "[remove] line $ssh_line from ~/.ssh/known_hosts\n";
            print `sed -i".bak" '${ssh_line}d' ~/.ssh/known_hosts`."\n";
            sleep(3);
            goto EXEC;
        }
        elsif( $l =~ m~(.*)ssh-keygen(.*)~) {
            print "[remove-key] ssh-keygen -f \"/home/ubuntu/.ssh/known_hosts\" -R $host\n";
            print `ssh-keygen -f \"/home/ubuntu/.ssh/known_hosts\" -R $host`."\n";
            sleep(3);
            goto EXEC;
        }
    }
}

sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//g;
        s/\s+$//g;
    }
    return wantarray ? @out : $out[0];
} # trim

