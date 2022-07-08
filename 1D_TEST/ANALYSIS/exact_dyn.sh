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
TMP_STRING=`ls -l n_wp/n_wp.*.dat | wc -l`
TMP=$((TMP_STRING))
UNO=1
NSTEPS=`expr $TMP - $UNO`
start=0
end=$NSTEPS
filename='exact_dyn'

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
     STEP='0000'$i
  elif [ $i -ge 10 -a $i -lt 100 ]
  then
     STEP='000'$i
  elif [ $i -ge 100 -a $i -lt 1000 ]
  then
     STEP='00'$i
  elif [ $i -ge 10000 ]
  then
     STEP='0'$i
  fi
  tdpesfile='./tdpes/tdpes.'$STEP'.dat'
  output='movie/plot_'$STEP'.gif'
  densityfile='./n_wp/n_wp.'$STEP'.dat'
    
echo "Plotting $i"

#gnuplot file
{
cat <<-EOF

set terminal gif
set out '$output'

set xtics -0.2,0.1,0.2
set xr [2:30]
set yr [-0.2:0.2]
set ytics nomirror
set y2tics 0,1,4
set y2r [0:4]
set xl "Position (bohr)"
set yl "Energy (hartree)"
set y2l "Nuclear density"

p 'BO_energy.dat' u 1:5 w l lw 4 lc rgb "red" t 'BO PES1', \
  'BO_energy.dat' u 1:6 w l lw 4 lc rgb "blue" t 'BO PES2', \
  '$tdpesfile' u 1:(\$2!=0.000 ? (\$2) : 1/0) \
        w p pt 7 ps 0.9 lc rgb "gray" t 'TDPES', \
  '$densityfile' u 1:(\$2+\$3) axis x1y2 w l lw 2 lc rgb "black" t 'DENSITY', \
  '$densityfile' u 1:2 axis x1y2 w l lw 1 lc rgb "red" t 'WP1', \
  '$densityfile' u 1:3 axis x1y2 w l lw 1 lc rgb "blue" t 'WP2'

EOF
} > plot.gp
gnuplot plot.gp

done

rm plot.gp

#Create animated gif
convert movie/*.gif  $filename.gif
rm -r movie
