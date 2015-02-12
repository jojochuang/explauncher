#!/bin/bash
source conf/conf.sh
source ../common.sh

gnuplot < $plotter/avg-latency.plot
cd result
epspdf avg-latency.eps
#mogrify -format png avg-latency.eps
convert -density 150  avg-latency.pdf avg-latency.png
rm avg-latency.eps

