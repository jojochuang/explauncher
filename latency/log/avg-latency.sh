#!/bin/bash

gnuplot < avg-latency.plot
#ls result/*.eps
epspdf result/avg-latency.eps
#ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png result/avg-latency.eps
rm result/avg-latency.eps

rm data/avg-latency.ts
