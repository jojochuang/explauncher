#!/usr/bin/gawk -f
# Rules:
BEGIN {

    # Accept any newline convention
    RS = "(\r\n|\n\r|\r|\n)"

    # Fields separation
    FS = " "

    # Keys init
    keys = 0
    #sum2_total = 0
    #start_time = 0
    #sum5_total = 0
    maxkey = 0

}

#Rules applied:
{
    # skip first line
    if ( NR == 1 ) {
      #next
      #start_time = int($1)
    }

    # fourth field is the key.
    k = int($4)
    #k = int($1-start_time)
    #if( k == 0 ) {next}
    #if(keys==0) {
      #start_time = k
      #k=0
    #}

    #printf("inserting to key[%.2f] start_time = %.2f\n", k, start_time);

    if (k in key) {
        # Already know key. Just sum.
        #printf("adding to key[%d] val = %.2f\n", k, $9);

        # count, lat, ratio
        cnt[k]++
        sum[k] += $9
        if( $9 > best[k] ) {
          best[k] = $9
        }
        if( $9 < worst[k] ) {
          worst[k] = $9
        }
        ss[k] += $9 * $9
    } else {
        # Add new key
        #printf("inserting to key[%d] val = %.2f\n", k, $9);
        #key[++keys] = k
        #key[++keys] = k
        key[k] = k
        cnt[k] = 1
        sum[k] = $9
        best[k] = $9
        worst[k] = $9
        ss[k] = $9 * $9
        if( k > maxkey ) {
          maxkey = k
        }
    }

}

# Final ruile:
END {
        #printf("RESULT\n");
        #printf("start_time = %.2f\n", start_time);
        for (i = 0; i <= maxkey; i++) {
          if( i in key ) {
            k = key[i]
            m = sum[k]/cnt[k]
            sd = sqrt( (ss[k] - cnt[k] * m * m) / ( cnt[k] - 1.0))
            se = sd / sqrt(cnt[k])
            #printf("%d %.2f %.2f %.2f %.2f\n", key[i], m, worst[k], best[k], se);
            printf("%d %.2f %.2f\n", key[i], m, se);
          }
        }
        #printf("sum2_total = %d\n", sum2_total);
        #printf("sum5_total = %d\n", sum5_total);
}
 

