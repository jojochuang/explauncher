#!/usr/bin/perl

# TODO: exit if no file name in the argument is given


$fn = $ARGV[0];


my %throughput;

open ( FILE, $fn );
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
}
close $FILE;

open( $FILE, '>', $fn );
# sort and output
for my $timeval ( sort {$a <=> $b} keys %throughput ){
  print $FILE "$timeval ".$throughput{ $timeval }."\n";
}

close $FILE;
