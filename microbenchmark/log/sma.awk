#!/usr/bin/awk -f
BEGIN {
  P=10
}

{
  x = $2; 
  i = NR % P; 
  MA += (x - Z[i]) / P; 
  Z[i] = x; 
  if(MA>=0) {
    printf("%d %.2f\n", $1, MA);
  } else{
    printf("%d 0.0\n", $1);
  }
}
  
