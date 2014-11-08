#!/bin/bash

application="throughput"
source ../common.sh

input="gv.out"


# get gv.out, the GraphViz file for the representation of the application services.
dot -Tpdf gv.out -o service_struct.pdf
dot -Tpng gv.out -o service_struct.png

