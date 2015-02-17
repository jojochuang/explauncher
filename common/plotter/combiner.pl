#!/usr/bin/perl


$out = $ARGV[0];
$in = $ARGV[1];
open ( FILE, $in );
open ( $OFILE, '>', $out );

while( <FILE> ){
    chomp;
    my @lines = split(" ");
    my $data_time = $lines[0];
    my $data_sum = 0.0;
    my $count= 0;
    for( my $i = 1; $i < @lines ; $i++ ){
        if( $lines[$i] > 0 ){
            $data_sum+= $lines[$i];
            $count++;
        }
    }
    my $data_avg = 0.0;
    if( $count > 0 ){
        $data_avg= $data_sum / $count;
    }
    #print "$data_time $data_sum\n";

    print $OFILE "$data_time $data_avg\n";
}
