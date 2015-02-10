#!/usr/bin/gawk -f
# Rules:
BEGIN {


    #
    # This script parses and prints out average and count.
    #

    # Accept any newline convention
    RS = "(\r\n|\n\r|\r|\n)"

    # Fields separation
    FS = " "

    # Keys init
    keys = 0
    #sum2_total = 0
    start_time = 0
    sum5_total = 0

}

#Rules applied:
{
    # skip first line
    if ( NR == 1 ) {
      #start_time = int($7)
      #next
    }

    # first field is the key.
    k = int($1)
    #printf("key = %d\n", k)
    #k = int($1-start_time)
    #if( k == 0 ) {next}
    #if(keys==0) {
      #start_time = k
      #k=0
    #}

    #printf("inserting to key[%.2f] start_time = %.2f\n", k, start_time);

    if (k in key) {
        # Already know key. Just sum.
        #printf("adding to key[%d] val = %.2f\n", k, $2);

        # count, lat, ratio
        sum5[k] += $2
        cnt[k] += 1
    } else {
        # Add new key
        #printf("inserting to key[k] val = %.2f\n", k, $5);
        #key[++keys] = k
        key[k] = k
        #keys++
        #printf("adding to key[%d] val = %.2f\n", k, $2);

        # count, lat, ratio
        sum5[k] = $2
        cnt[k] = 1
    }
}

# Final ruile:
END {
        #printf("RESULT\n");
        #printf("start_time = %.2f\n", start_time);
        for ( i in key ) {
        #for (i = 0; i < keys; i++) {
            k = key[i]
            #printf("%d", key[i])
            if( cnt[k] >= 1 ) {
              printf("%d\t%.2f\t%d\n", key[i], (sum5[k]/cnt[k]), cnt[k]);
            } else {
              printf("%d\t0\n", key[i]);
            }
        }
        #printf("sum2_total = %d\n", sum2_total);
        #printf("sum5_total = %d\n", sum5_total);
}
 

