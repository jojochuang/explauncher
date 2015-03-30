#!/bin/bash
source conf/conf.sh
source ../common.sh

echo "start avg-client.sh"

gnuplot < $plotter/avg-client.plot
#ls result/*.eps
cd result
epspdf avg-client.eps
convert -density 150  avg-client.pdf avg-client.png
rm avg-client.eps
echo "end avg-client.sh"

