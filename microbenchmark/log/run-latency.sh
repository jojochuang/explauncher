# generate sorted result.

app="microbenchmark"
logdir=/u/tiberius06_s/yoo7/logs/microbenchmark

type="latency"

if [[ "$type" = "latency" ]]; then
  echo "generating latency result"
  logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final02-context-size-latency
fi



# (Plotting migration latency by varying context size)
# Generate "combined table" of all experiments.
./parse-latency.sh $logdir > data/latency-all.dat

# Get the list of identifiers
ids=(`cat data/latency-all.dat | awk '{print $2}' | uniq`)

# Generate throughput-added file for each identifiers.

for i in "${ids[@]}"; do
  echo "* Procesing id = $i"
  grep " ${i} " data/latency-all.dat | sed '/^$/d' | sort -t' ' -k7,7n | awk '{print $1" "$2" "$7" "$4" "$5" "$6" "$8" "$9" "($8/$9/1000)}' | ./group.awk | sort -t' ' -k +1n -k +2n -k +3n > data/latency-id-${i}.dat
  cat data/latency-id-${i}.dat
  echo ""

  # Now plotting with group.py
  ./plot-latency.py -i data/latency-id-${i}.dat -o result/latency-id-${i}.pdf
done



#grep " nocpu_single_global" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' > result-nocpu_single_global.dat
#grep " cpusamehead" result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' > result-cpu.dat
#grep "contextnull" result.dat | grep "default" | sed '/^$/d' | sort -t' ' -k5,5n > result-contextnull.dat

#cat result-cpu.dat | ./microbenchmark.awk > result-cpu-plot.dat
#cat result-nocpu_single_global.dat | ./microbenchmark.awk > result-nocpu_single_global-plot.dat


# Generating summed value

#gnuplot < ${app}.plot

#ls *.eps | xargs --max-lines=1 epspdf

#pdflatex ${app}.tex



