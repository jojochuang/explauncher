#!/bin/bash
source conf/config.sh
ec2-host -k $ACCESS_KEY -s $SECRET_KEY shyoo-mace-slave | awk '{print $2}' | xargs --max-lines=1 -I {} host {} | awk '{print $4, $1}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | awk '{print $2}' > conf/slave
cat conf/slave | xargs --max-lines=1 -I {} ssh {} "pwd"
#pssh -h all-list.txt chmod 400 ~/.ssh/shyoo.pem
#cat all-list.txt | xargs --max-lines=1 -I {} rsync -vauz ~/maceclean-project/ {}:~/maceclean-project
#cat all-list.txt | xargs --max-lines=1 -I {} rsync -vauz ~/mace-project/ {}:~/mace-project
#cp all-list.txt fullcontext-list.txt
#./process-list.rb all fullcontext
