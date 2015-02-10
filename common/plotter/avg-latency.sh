#!/bin/bash
source conf/conf.sh
source ../common.sh

gnuplot < $plotter/avg-latency.plot
epspdf result/avg-latency.eps
mogrify -format png result/avg-latency.eps
rm result/avg-latency.eps

