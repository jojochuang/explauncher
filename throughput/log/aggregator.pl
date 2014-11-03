#!/usr/bin/perl

# TODO: exit if no file name in the argument is given


$fn = $ARGV[0];
$nargs = scalar( @ARGV ) -1;
my $logdir_label = $ARGV[ $nargs ];


my %throughput;

my $total_throughput = 0;
for ($n = 1; $n < $nargs; $n++ ){
  open ( FILE, $ARGV[$n] );
  while( <FILE> ){
    chomp;
    my @lines = split("\t");
    my $data_time = $lines[0];
    my $data_throughput = $lines[1];

    if ( not exists $throughput{ $data_time } ){
      $throughput{ $data_time } = $data_throughput;
    }else{
      $throughput{ $data_time } += $data_throughput;
    }
    $total_throughput += $data_throughput;
  }
  close FILE;
}

my $min_threshold = $total_throughput * 0.1;
my $max_threshold = $total_throughput * 0.9;

my $min_time;
my $max_time;
open( FILE, '>>', $fn );
# sort and output
my $sum_throughput = 0;
for my $timeval ( sort {$a <=> $b} keys %throughput ){
  #print $FILE "$timeval ".$throughput{ $timeval }."\n";
  $sum_throughput += $throughput{ $timeval };
  if( not defined $min_time and $sum_throughput >= $min_threshold ){
    $min_time = $timeval;
  }
  if( not defined $max_time and $sum_throughput >= $max_threshold ){
    $max_time = $timeval - 1;
  }
  #print "$timeval $sum_throughput " . $throughput{ $timeval } . "\n";
}
# find # total events
# find when 10% event is finished
# find when 90% event is finished
# compute average throughput = ( ev at 90% - ev at 10% )/( time at 90% - time at 10% )
my $max_throughput = $throughput{ $max_time };
my $min_throughput = $throughput{ $min_time };
my $avg = ( $max_throughput - $min_throughput ) / ( $max_time - $min_time );
print FILE "$total_throughput $max_throughput $max_time $min_throughput $min_time $avg LABEL:$logdir_label\n";
close FILE;
