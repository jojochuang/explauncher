# generate sorted result.

#app="microbenchmark"
logdir=final01-cloud

cd $logdir

#file=(`find $logdir -name '*.log' | sort`)
file=(`find ./ -name '*.log' | sort`)

# For each file, print out GET and PUT logs

for f in "${file[@]}"; do
  #echo "$f"
  g=$(basename "$f")
  #echo "$g"
  i="${g%%.*}"
  echo "processing id = ${i}"
  start_time=`grep "Starting" $f | head -1 | awk '{print $4}' | tr -d '\r\n'`
  start_time=$(($start_time / 1000000))
  #echo "start = ${t}"

  #grep "GET" $f | grep "BS_KeyValueClient" | awk "{ T=int(\$1 - $start_time); print T\" \"\$8}" | ../timeseries.awk | sort -k +1n > $i.get
  #grep "PUT" $f | grep "BS_KeyValueClient" | awk "{ T=int(\$1 - $start_time); print T\" \"\$8}" | ../timeseries.awk | sort -k +1n > $i.put

  # Parse sar log

  # do some cleanup
  rm *.tmp

  #rm $i.mem $i.swap $i.fault $i.commit
  sarfiles=(`find ./ -name '*.sar'| grep -e "/${i}" | sort`)

  for sarfile in "${sarfiles[@]}"; do
    echo "sarfile = $sarfile"
    #j="${sarfile%%.*}"

    #echo "processing sa = ${j}"

    sadf -- -B -r -S $sarfile | grep %memused | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" >> $i.mem.tmp
    sadf -- -B -r -S $sarfile | grep %swpused | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" >> $i.swap.tmp
    sadf -- -B -r -S $sarfile | grep fault | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" >> $i.fault.tmp
    sadf -- -B -r -S $sarfile | grep %commit | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {printf \"%d\t%.3f\n\", T, (\$6/100.0)}}" >> $i.commit.tmp
  done

  headsarfiles=(`find ./ -name '*.sar'| grep -e "/${i}" | sort | head -1`)

  for sarfile in "${headsarfiles[@]}"; do
    echo "headsarfile = $sarfile"
    #j="${sarfile%%.*}"

    #echo "processing sa = ${j}"

    sadf -- -B -r -S $sarfile | grep %memused | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" > $i.head.mem
    sadf -- -B -r -S $sarfile | grep %swpused | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" > $i.head.swap
    sadf -- -B -r -S $sarfile | grep fault | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {print T\"\t\"\$6}}" > $i.head.fault
    sadf -- -B -r -S $sarfile | grep %commit | awk "{ T=int(\$3 - $start_time); if( T > 0 ) {printf \"%d\t%.3f\n\", T, (\$6/100.0)}}" > $i.head.commit
  done


  # aggregate them
  cat $i.mem.tmp | ../timeseries-bwa.awk | sort -k +1n > $i.mem
  cat $i.swap.tmp | ../timeseries-bwa.awk | sort -k +1n > $i.swap
  cat $i.fault.tmp | ../timeseries-bwa.awk | sort -k +1n > $i.fault
  cat $i.commit.tmp | ../timeseries-bwa.awk | sort -k +1n > $i.commit

done


#./parse-group.sh $logdir > data/group-all.dat

## Get the list of identifiers
#ids=(`cat result.dat | awk '{print $2}' | uniq`)

## Generate throughput-added file for each identifiers.

#for i in "${ids[@]}"; do
  #echo "* Procesing id = $i"
  #grep " ${i} " data/group-all.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./group.awk | sort -t' ' -k +1n -k +2n -k +3n > data/group-id-${i}.dat
  #cat data/group-id-${i}.dat
  #echo ""

  ## Now plotting with group.py
  #./plot-group.py -i data/group-id-${i}.dat -o result/group-id-${i}.pdf
#done



#grep " nocpu_single_global" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' > result-nocpu_single_global.dat
#grep " cpusamehead" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' > result-cpu.dat
#grep "contextnull" result.dat | grep "default" | sed '/^$/d' | sort -t' ' -k5,5n > result-contextnull.dat

#cat result-cpu.dat | ./microbenchmark.awk > result-cpu-plot.dat
#cat result-nocpu_single_global.dat | ./microbenchmark.awk > result-nocpu_single_global-plot.dat


# Generating summed value

#gnuplot < ${app}.plot

#ls *.eps | xargs --max-lines=1 epspdf

#pdflatex ${app}.tex



