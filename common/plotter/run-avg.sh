#!/bin/bash
source conf/conf.sh
source ../common.sh

gnuplot < $plotter/avg-throughput.plot
#ls result/*.eps
cd result
epspdf avg-throughput.eps
#ls *.eps | xargs --max-lines=1 epspdf
#mogrify -format png avg-throughput.eps
convert -density 150  avg-throughput.pdf avg-throughput.png
rm avg-throughput.eps
