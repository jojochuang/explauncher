#!/usr/bin/perl

my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $label = $ARGV[2];

open FILE, $infile;
my $sum = 0;
my $count = 0;

my $avg = 0.0;
my @avgs;
while( <FILE> ){
  chomp;
  my @line = split(' ');
  my $per_avg = $line[5];
  push @avgs, $per_avg;
  $sum += $per_avg;
  $count++;
}

$avg = $sum / $count;

my $tmp_sq= 0;
foreach my $v ( @avgs ){
  $tmp_sq += ($v-$avg) * ( $v-$avg );
}
my $stddev = sqrt( $tmp_sq/ $count );

close FILE;

open OUTFILE, ">>", $outfile;
print OUTFILE "$label $avg $stddev\n";
close OUTFILE;
