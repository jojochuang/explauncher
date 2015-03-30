#!/usr/bin/perl

# TODO: exit if no file name in the argument is given


$out = $ARGV[0];
#$out = $ARGV[1];

$nargs = scalar( @ARGV );


my %throughput;
#print "nargs = $nargs\n";

my $max_time;
my $min_time;
my @all_data;
for ($n = 1; $n < $nargs; $n++ ){
  open ( FILE, $ARGV[$n] );
  print "open " . $ARGV[$n] . "\n";
  my %tmp;
  while( <FILE> ){
    chomp;
    my @lines = split("\t");
    my $data_time = $lines[0];
    my $data_throughput = $lines[1];

    #print "|$data_time|\t |$data_throughput|\n";
    $tmp{ $data_time }= $data_throughput;

    if( not defined $max_time or $max_time < $data_time ){
      $max_time = $data_time;
    }
    if( not defined $min_time or $min_time > $data_time ){
      $min_time = $data_time;
    }
  }
  close $FILE;
  push @all_data, \%tmp;

}
print "max time = $max_time, min_time = $min_time\n";
for( my $n=$min_time; $n<= $max_time; $n++ ){
  foreach my $data_set (@all_data){
    if( not defined $data_set->{ $n }  ){
      push @{ $throughput{ $n }  }, 0;
      #print "0\n";
    }else{
      push @{ $throughput{ $n }  }, $data_set->{ $n };
      #print $data_set->{ $n } . "\n";
    }
  }
}

open( $FILE, '>', $out );
# sort and output
for my $timeval ( sort {$a <=> $b} keys %throughput ){
  my $str = "$timeval ";
  foreach my $v ( @{ $throughput{ $timeval } } ){
    $str .= " " . $v;
  }
  print $FILE "$str\n";
  print "$str\n";
}

close $FILE;

