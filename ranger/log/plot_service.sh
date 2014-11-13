#!/bin/bash

application="ranger"
source ../../common.sh

./parse-service.sh

cwd=`pwd`
# generated from parse-service.sh
input="${cwd}/data/head-sv.dot"

# get gv.out, the GraphViz file for the representation of the application services.
dot -Tpdf $input -o ${cwd}/result/service_struct.pdf
dot -Tpng $input -o ${cwd}/result/service_struct.png

