#!/usr/bin/perl
#print scalar( @ARGV );

$filename = $ARGV[0];

my $local_ip;
my $local_port;
my $remote_ip;
my $remote_port;

my %remote_nodes;
open( FILE, $filename );
while( <FILE> ){
  chomp;
  my @line = split(" ");
  #print $line[1] . "\n";
  if( $line[2] =~ "TcpTransport::connect" ){
    my $remote_addr = $line[5];
    my $remote_port_str = $line[9];
    my $port_offset_str = $line[10];
    my $local_port_str = $line[11];

    #print "remote_addr = $remote_addr , remote_port = $remote_port_str , port_offset = $port_offset_str , local_port = $local_port_str\n";

    my @addr_pair = split(":", $remote_addr );
    $remote_ip = $addr_pair[0];

    my @remote_port_array = split("=", $remote_port_str );
    $remote_port = $remote_port_array[1];

    my @port_offset_array = split("=", $port_offset_str );
    my $port_offset = $port_offset_array[1];

    die if $port_offset + $remote_port != $addr_pair[1];

    my @local_port_array = split("=", $local_port_str );
    my $tmp_local_port = $local_port_array[1];
    $tmp_local_port -= $port_offset;

    die if $tmp_local_port != $local_port;

    #print "remote_ip = $remote_ip, remote_port = $remote_port, local_port = $local_port\n";

    $remote_nodes{"$remote_ip:$remote_port" } = 1;
  }elsif ($line[2] =~ "BaseTransport::BaseTransport" ){
    next if $line[3] ne "listening";

    my $local_addr_str = $line[7];
    #print "-->" . $local_addr_str . "\n";
    my @local_addr_array = split("=", $local_addr_str );
    #print "-->" . $local_addr_array[1] . "\n";
    my @local_addr = split(":", $local_addr_array[1] );
    $local_ip = $local_addr[0];
    $local_port = $local_addr[1];
    #print "local ip = $local_ip, local port = $local_port\n";
  }
}
foreach my $key ( keys %remote_nodes ) {
  print "  \"$local_ip:$local_port\" -> \"$key\";\n";
}
#print "remote_ip = $remote_ip, remote_port = $remote_port, local ip = $local_ip, local_port = $local_port\n";
close FILE;
