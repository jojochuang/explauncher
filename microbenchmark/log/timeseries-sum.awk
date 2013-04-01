#!/usr/bin/gawk -f
# Rules:
BEGIN {

    #
    # This script parse timeseries data and prints out "timeseries sum_for_timeframe"
    #

    # Accept any newline convention
    RS = "(\r\n|\n\r|\r|\n)"

    # Fields separation
    FS = " "

    # Keys init
    keys = 0
    #sum2_total = 0
    start_time = 0

}

#Rules applied:
{
    # skip first line
    if ( NR == 1 ) {
      #start_time = int($7)
      #next
    }

    # first field is the key.
    k = int($7-start_time)
    #k = int($1-start_time)
    #if( k == 0 ) {next}
    if(keys==0) {
      start_time = k
      k=0
    }

    #printf("inserting to key[%.2f] start_time = %.2f\n", k, start_time);

    if (k in key) {
        # Already know key. Just sum.
        #printf("adding to key[%d] val = %.2f\n", k, $5);

        # count, lat, ratio
        sum5[k] += $9
    } else {
        # Add new key
        #printf("inserting to key[k] val = %.2f\n", k, $5);
        #key[++keys] = k
        key[k] = k
        keys++

        # count, lat, ratio
        sum5[k] = $9
    }
}

# Final ruile:
END {
        #printf("RESULT\n");
        #printf("start_time = %.2f\n", start_time);
        for (i = 0; i < keys; i++) {
            k = key[i]
            printf("%d %.2f\n", key[i], sum5[k]);
        }
        #printf("sum2_total = %d\n", sum2_total);
}
 

