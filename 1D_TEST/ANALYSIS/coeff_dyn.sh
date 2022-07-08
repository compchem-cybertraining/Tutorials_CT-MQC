#!/bin/bash

function usage() {
    cat <<EOF

    Copyright (C) 2022 by Federica Agostini
    traj_on_PES.sh
    
     -h         Print usage
     -s         Starting step
     -f         Final step
     -n         Name of the output file
     
    Report to <federica.agostini@universite-paris-saclay.fr>.

EOF
  exit 0;
}

# Default:
TMP_STRING=`ls -l coeff/coeff.*.dat | wc -l`
TMP=$((TMP_STRING))
UNO=1
NSTEPS=`expr $TMP - $UNO`
start=0
end=$NSTEPS
filename='coeff_dyn'

while getopts "hs:f:n:" arg ; do
    case "$arg" in
	h) usage ;;
	s) start="$OPTARG" ;;
    f) end="$OPTARG" ;;
    n) filename="$OPTARG" ;;
    esac
done

# If no argument:
[ "$#" -eq 0 ] && usage;

[ ! -d movie ] && mkdir movie
rm -f movie/*.gif

#Loop over the RPE files
for ((i = 0 ; i <= $end ; i++)); do
  if [ $i -lt 10 ]
  then
     STEP='000'$i
  elif [ $i -ge 10 -a $i -lt 100 ]
  then
     STEP='00'$i
  elif [ $i -ge 100 -a $i -lt 1000 ]
  then
     STEP='0'$i
  elif [ $i -ge 10000 ]
  then
     STEP=''$i
  fi
  datafile='./coeff/coeff.'$STEP'.dat'
  output='movie/plot_'$STEP'.gif'
    
echo "Plotting $i"

#gnuplot file
{
cat <<-EOF

set terminal gif
set out '$output'

set xr [2:30]
set ytics 0,0.2,1
set yr [-0.05:1.05]
set xl "Position (bohr)"
set yl "Population / Coherence"

p '$datafile' u 1:2 w p pt 4 ps 0.8  lc rgb "red" t 'FOR STATE 1', \
  '$datafile' u 1:5 w p pt 6 ps 0.8 lc rgb "blue" t 'FOR STATE 2', \
  '$datafile' u 1:(\$2*\$5) w p pt 26 ps 0.4 lc rgb "black" t 'COHERENCE'

EOF
} > plot.gp
gnuplot plot.gp

done

rm plot.gp

#Create animated gif
convert movie/*.gif  $filename.gif
rm -r movie
