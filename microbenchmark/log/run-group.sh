# generate sorted result.

app="microbenchmark"
#logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final01-cpuload
#logdir=/u/tiberius06_s/yoo7/logs/microbenchmark
logdir=/home/ubuntu/logs/microbenchmark

# Generate "combined table" of all experiments.
#type="var_cpuload"
type="fixed_cpuload"

if [[ "$type" = "var_cpuload" ]]; then
  echo "generating var_cpuload"
  logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final01-cpuload
elif [[ "$type" = "fixed_cpuload" ]]; then
  echo "generating fixed_cpuload"
  #logdir=/u/tiberius06_s/yoo7/logs/microbenchmark_archive/final03-cpuload-fixedcontexts
fi


./parse-group.sh $logdir > data/group-all.dat

# Get the list of identifiers
ids=(`cat data/group-all.dat | awk '{print $2}' | uniq`)

# Generate throughput-added file for each identifiers.

for i in "${ids[@]}"; do
  echo "* Procesing id = $i"
  grep " ${i} " data/group-all.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./group.awk | sort -t' ' -k +1n -k +2n -k +3n > data/group-id-${i}.dat
  cat data/group-id-${i}.dat
  echo ""

  if [[ "$type" = "var_cpuload" ]]; then
    # Now plotting with group.py
    ./plot-group-varcpu.py -i data/group-id-${i}.dat -o result/group-id-${i}.pdf
  elif [[ "$type" = "fixed_cpuload" ]]; then
    # Now plotting with group.py
    ./plot-group-fixcpu.py -i data/group-id-${i}.dat -o result/group-id-${i}.pdf
  fi
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



