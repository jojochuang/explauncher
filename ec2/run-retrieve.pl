#!/usr/bin/perl -w

use strict;
use Getopt::Long;
#use Math;

unless (@ARGV) {
    print "usage: $0\n";
    print "  -m (rsync maceclean-project)\n";
    print "  -f (rsync mace-project)\n";

    print "  -r (regenerate conf/slave from conf/instance)\n";
    print "  -p (do parallel ssh for pwd)\n";
    print "  -t (terminate all running instances)\n";
    print "  -a [create add start stop terminate] instances\n";

    print "  -s (sync machine lists)\n";
    print "  -i (create new ami image)\n";
    print "  -d (instance name to delete)\n";

}


my $mace_rsync = 0;
my $fullcontext_rsync = 0;
my $pssh = 0;
my $action = "";
my $regenerate = 0;
my $num_instances = 0;
my $sync = 0;
my $image_create = 0;
my $delete = "";

GetOptions("mace_rsync" => \$mace_rsync,
           "fullcontext_rsync" => \$fullcontext_rsync,
           "pssh" => \$pssh,
           "action=s" => \$action,
           "regenerate" => \$regenerate,
           "sync" => \$sync,
           "image_create" => \$image_create,
           "delete=s" => \$delete,
           "num_instances=i" => \$num_instances,
       );


my $ec2_key = "AKIAIGXNKNV5WAFF2CWA";
my $ec2_pass = "kA1nDQ9KmnTf0DhiK9hxL39mUYA4Kb7s8rxHuc4V";
my $ec2_instance = "i-42849d3f";

#sed -i".bak" '/ecdsa/d' known_hosts
#my $ami_id = "ami-3a49f353";

# Create new AMI image
if( $image_create ) {
    my $ami_name_old = trim(`cat conf/ami-id | awk '{print \$1}'`);
    my $ami_name_new = $ami_name_old+1;
    my $run = "ec2-create-image -O ${ec2_key} -W ${ec2_pass} ${ec2_instance} -name shyoo-mace${ami_name_new} --no-reboot | awk '{print \$2}'";
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
    print "\$ ${run}\n";
    print `$run`;
}

# Create instances
if( $action eq "CREATE" ) {
    my $run = "ec2-run-instances -O ${ec2_key} -W ${ec2_pass} ${ami_id} -n ${num_instances} -k shyoo -t m1.small --availability-zone us-east-1a | grep INSTANCE | awk '{print \$2}'";
    print "\$ ${run}\n";

    open STDERR, ">&STDOUT" or die( "can't redirect STDERR");
    my @instances = `$run`;
    my $instances_list = join(" ", map { trim($_) } @instances); 

    print "Created instances : ${instances_list}\n";

    # print instance-list.txt
    open(OUT, ">conf/instance") or die "cannot open conf/instance for output";
    print OUT join("\n", map { trim($_) } @instances)."\n";
    close(OUT);

    ## print all-list.txt
    #$run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$4}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    #print "\$ ${run}\n";

    #my @hosts = `$run`;
    #open(OUT, ">all-list.txt") or die "cannot open all-list.txt for output";
    #print OUT join("\n", map { trim($_) } @hosts);
    #print "Hosts : ".join(" ", map { trim($_) } @hosts)."\n";
    #close(OUT);

}

if( $action eq "ADD" ) {
    my $run = "ec2-run-instances -O ${ec2_key} -W ${ec2_pass} ${ami_id} -n ${num_instances} -k shyoo -t m1.small | grep INSTANCE | awk '{print \$2}'";
    print "\$ ${run}\n";

    open STDERR, ">&STDOUT" or die( "can't redirect STDERR");
    my @instances = `$run`;
    my $instances_list = join(" ", map { trim($_) } @instances); 

    print "Added instances : ${instances_list}\n";

    # print instance-list.txt
    open(OUT, ">>conf/instance") or die "cannot open conf/instance for output";
    print OUT join("\n", map { trim($_) } @instances)."\n";
    close(OUT);

    ## print all-list.txt
    #$run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$4}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    #print "\$ ${run}\n";

    #my @hosts = `$run`;
    #open(OUT, ">all-list.txt") or die "cannot open all-list.txt for output";
    #print OUT join("\n", map { trim($_) } @hosts);
    #print "Hosts : ".join(" ", map { trim($_) } @hosts)."\n";
    #close(OUT);

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

# Generate all-list.txt if needed
if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" || $delete || $regenerate )
{
    if( $action eq "CREATE" || $action eq "ADD" ) {
        sleep(30);
    }
    open(FILE, "conf/instance") or die "cannot open conf/instance for read";
    my @instances = <FILE>;
    my $instances_list = join(" ", map { trim($_) } @instances); 
    close FILE;

    print "Listed instances : ${instances_list}\n";

    #my $run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$4}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    my $run = "ec2-describe-instances -O ${ec2_key} -W ${ec2_pass} ${instances_list} | grep INSTANCE | awk '{print \$5}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'";
    print "\$ ${run}\n";

    my @hosts = `$run`;
    open(OUT, ">conf/slave") or die "cannot open conf/slave for output";
    print OUT join("\n", map { trim($_) } @hosts)."\n";
    print "Hosts : ".join(" ", map { trim($_) } @hosts)."\n";
    close(OUT);
}

#exit(0);

# Retrieve machine list

#my @hosts = `ec2-host -k ${ec2_key} -s ${ec2_pass} shyoo-mace-slave | awk '{print \$2}' | xargs --max-lines=1 -I {} host {} | awk '{print \$4, \$1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print \$2}'`;

#open(OUT, ">all-list.txt") or die "cannot open all-list.txt for output";
#print OUT join("\n", map { trim($_) } @hosts);
#close(OUT);
open(FILE, "conf/slave") or die("Unable to read conf/slave\n");
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

if( $mace_rsync ) {
    print "\$ cat conf/slave | xargs --max-lines=1 -I {} rsync -vauz ~/maceclean-project/ {}:~/maceclean-project\n";
    print `cat conf/slave | xargs --max-lines=1 -I {} rsync -vauz ~/maceclean-project/ {}:~/maceclean-project`
}

if( $fullcontext_rsync) {
    print "\$ cat conf/slave | xargs --max-lines=1 -I {} rsync -vauz ~/mace-project/ {}:~/mace-project\n";
    print `cat conf/slave | xargs --max-lines=1 -I {} rsync -vauz ~/mace-project/ {}:~/mace-project`
}
    
print "\$ cp all-list.txt fullcontext-list.txt\n";
print "\$ cp all-list.txt gol-list.txt\n";
print `cp all-list.txt fullcontext-list.txt`;
print `cp all-list.txt gol-list.txt`;
print "\$ ./process-list.rb all fullcontext gol\n";
print `./process-list.rb all fullcontext gol`;

if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" || $sync ) {
    if( $action eq "CREATE" || $action eq "ADD" || $action eq "START" ) {
        sleep(30);
    }
    print "\$ /home/ubuntu/pssh-2.2/bin/pscp -h conf/slave ~/machine-list/* ~/machine-list"."\n";
    print `/home/ubuntu/pssh-2.2/bin/pscp -h conf/slave ~/machine-list/* ~/machine-list`."\n";
}

sub subexecute {
    my $cmd = shift;
    my $host = trim(shift);
    my $rcmd = shift;

EXEC:
    my $exec = qq{sh -c "$cmd $host $rcmd 2>&1"};

    #print "* RUNNING : $exec\n";

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
                                
