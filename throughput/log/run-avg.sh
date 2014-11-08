#!/bin/bash

gnuplot < avg-throughput.plot
ls *.eps | xargs --max-lines=1 epspdf
mogrify -format png *.eps
rm *.eps
