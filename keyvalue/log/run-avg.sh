#!/bin/bash

gnuplot < avg-throughput.plot
#ls result/*.eps
epspdf result/avg-throughput.eps
#ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png result/avg-throughput.eps
rm result/avg-throughput.eps
