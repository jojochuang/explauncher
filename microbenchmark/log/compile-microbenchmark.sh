# generate sorted result.

app="microbenchmark"

./aggregate-${app}.sh > result.dat
#grep "unit" result.dat | grep "default" | sed '/^$/d' | sort -t' ' -k5,5n > result-unit.dat

# Get the list of identifier
ids=(`cat result.dat | awk '{print $2}' | uniq`)


for i in "${ids[@]}"; do
  echo "* Procesing id = $i"
  grep " ${i} " result.dat | sed '/^$/d' | sort -t' ' -k4,4n | awk '{print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "(1000000*$8/$7)}' | ./microbenchmark.awk | sort -t' ' -k +1n -k +2n > result-${i}.dat
  cat result-${i}.dat
  echo ""
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



