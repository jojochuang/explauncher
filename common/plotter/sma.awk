#!/usr/bin/awk -f
BEGIN {
  P=20
}

{
  x = $2; 
  i = NR % P; 
  MA += (x - Z[i]) / P; 
  Z[i] = x; 
  if(MA>=0) {
    printf("%f %.2f\n", $1, MA);
  } else{
    printf("%f 0.0\n", $1);
  }
}
  
