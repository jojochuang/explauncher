#!/usr/bin/perl
my $infile = $ARGV[0];
my $bootfile = $ARGV[1];
my $outfile = $ARGV[2];

my %nodes;
print "before parsing boot\n";

# use the boot file to categorize nodes
open $BOOT, $bootfile;
while ( <$BOOT> ){
  chomp;
  my @line = split(' ');
  my $addr = $line[2];
  my $node_type = $line[4];
  $nodes{ $addr } = $node_type;
}
close $BOOT;
#print "after parse boot file\n";

my %connections;
open $IN, $infile;
while ( <$IN> ){
  chomp;
  my @line = split(' ');
  my $conn_from = $line[0];
  my $conn_to = $line[2];
  #$connections{ $conn_from } = $conn_to;
  push @{ $connections{ $conn_from } }, $conn_to;
}
close $IN;
#print "after parse intermediate file\n";

open $OUT, '>', $outfile;
print $OUT "graph Connection {\n";
# print sub graphs
#print $OUT "  subgraph server {\n";
print $OUT "  edge [len=3]";
while ( ( $from , $to_array ) = each %connections ) {
  foreach my $to ( @{$to_array} ){
    #print "$from $to\n";
    if( ($nodes{ $from } eq "head" or $nodes{ $from } eq "server" ) and 
      ($nodes{ $to } eq "head" or $nodes{ $to } eq "server" ) ){

        print $OUT "  \"$from\" -- \"$to\";\n";
    }
  }
}

#print $OUT "    label = \"server\";\n";
#print $OUT "  }\n";
# print links between sub graphs
print $OUT "  node [shape=box, style=filled]\n";
while ( ( $from , $to_array ) = each %connections ) {
  foreach my $to ( @{$to_array} ){
    #print "$from $to\n";
    if( not( ($nodes{ $from } eq "head" or $nodes{ $from } eq "server" ) and 
      ($nodes{ $to } eq "head" or $nodes{ $to } eq "server" ) ) ){
        print $OUT "  \"$from\" -- \"$to\";\n";
    }
  }
}
print $OUT "}\n";
close $OUT;
