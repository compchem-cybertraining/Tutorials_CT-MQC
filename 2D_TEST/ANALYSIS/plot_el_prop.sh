#!/bin/bash

echo "Path to directory with exact data"
read ex_dir
filepop=$ex_dir'/BO_population.dat'
filecoh=$ex_dir'/BO_coherences.dat'

#gnuplot file
{
cat <<-EOF

set term post col enhanced
set output "el_prop.ps"

set style line 1 lt 1 lw 4 lc rgb "red"
set style line 2 lt 1 lw 4 lc rgb "blue"
set style line 3 lt 1 lw 1 pt 4 ps 0.5 lc rgb "red"
set style line 4 lt 1 lw 1 pt 4 ps 0.5 lc rgb "blue"
set style line 5 lt 1 lw 4 lc rgb "black"
set style line 6 lt 1 lw 3 lc rgb "orange"
set style line 7 lt 1 lw 3 lc rgb "cyan"
set style line 8 lt 1 lw 3 lc rgb "gray"

set key top right font ",15"
set key opaque

set title ""

set xtics 0,5,25 font ",15"
set xr [0:25]
set xl "Time (fs)" font ",15"

set ytics 0,0.2,1 font ",15"
set yr[-0.05:1.05]
set yl "Population" font ",15"
set ytics nomirror
set y2tics 0,0.01,0.03 font ",15"
set y2r[0:0.03]
set y2l "Indicator of coherence" font ",15"

p 'BO_population.dat' u (\$1*0.024):2 w l ls 1 t 'ground state', \
  'BO_population.dat' u (\$1*0.024):3 w l ls 2 t 'excited state', \
  'BO_population.dat' u (\$1*0.024):4 every 5 w lp ls 3 t '', \
  'BO_population.dat' u (\$1*0.024):5 every 5 w lp ls 4 t '', \
  '$filepop' u (\$1*0.024):2 w l ls 6 t 'exact ground state', \
  '$filepop' u (\$1*0.024):3 w l ls 7 t 'exact excited state', \
  'BO_coherences.dat' u (\$1*0.024):2 axis x1y2 w l ls 5 t 'coherence'

EOF
} > plot.gp
gnuplot plot.gp

rm plot.gp

ps2pdf el_prop.ps
rm el_prop.ps

