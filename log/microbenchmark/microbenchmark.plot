
#set bmargin 5


set border 3
set xtics nomirror
set ytics nomirror
set terminal postscript enhanced eps color "Helvetica" 22
set ylabel "Processed events (sec)" font "Helvetica,20"
#set yrange [-.05:1.1]
#set ytics 0,.25,1
set xtics nomirror rotate by -45
set mytics 5
set style data linesp

# MaceKen:    circle, black
# Plain Mace: triangle, red
# get:    hollow, thin lines
# prior:  filled, thick lines

#unset key


set xlabel "GOL Creation" font "Helvetica,20"
set output "gol-gen.eps"

plot \
  'result-unit.dat'       using ($7/1000000):xticlabel(5) title "GOL(single) in Plain mace"     lt -1 pt 6 lw 1, \
  'result-contextnull.dat'    using ($7/1000000):xticlabel(5) title "GOL(single) in Context mace"   lt  1 pt 6 lw 1, \
  'result-context.dat'    using ($7/1000000):xticlabel(5) title "GOL(context) in Context mace"   lt  9 pt 9 lw 1

  

#set xlabel "GOL Computation" font "Helvetica,20"
#set output "gol-comonly.eps"

#plot \
  #'result-unit.dat'       using ($9/1000000):xticlabel(5) title "GOL(single) in Plain mace"     lt -1 pt 6 lw 1, \
  #'result-contextnull.dat'    using ($9/1000000):xticlabel(5) title "GOL(single) in Context mace"   lt  1 pt 6 lw 1, \
  #'result-context.dat'    using ($9/1000000):xticlabel(5) title "GOL(context) in Context mace"   lt  9 pt 9 lw 1



#set xlabel "GOL Computation + Messaging" font "Helvetica,20"
#set output "gol-com.eps"

#plot \
  #'result-unit.dat'       using ($8/1000000):xticlabel(5) title "GOL(single) in Plain mace"     lt -1 pt 6 lw 1, \
  #'result-contextnull.dat'    using ($8/1000000):xticlabel(5) title "GOL(single) in Context mace"   lt  1 pt 6 lw 1, \
  #'result-context.dat'    using ($8/1000000):xticlabel(5) title "GOL(context) in Context mace"   lt  9 pt 9 lw 1


#set xlabel "GOL Total (Creation + Compuation + Messaging)" font "Helvetica,20"
#set output "gol-all.eps"

#plot \
  #'result-unit.dat'       using (($7+$8)/1000000):xticlabel(5) title "GOL(single) in Plain mace"     lt -1 pt 6 lw 1, \
  #'result-contextnull.dat'    using (($7+$8)/1000000):xticlabel(5) title "GOL(single) in Context mace"   lt  1 pt 6 lw 1, \
  #'result-context.dat'    using (($7+$8)/1000000):xticlabel(5) title "GOL(context) in Context mace"   lt  9 pt 9 lw 1

