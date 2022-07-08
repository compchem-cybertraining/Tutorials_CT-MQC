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
TMP_STRING=`ls -l trajectories/RPE.*.dat | wc -l`
TMP=$((TMP_STRING))
UNO=1
NSTEPS=`expr $TMP - $UNO`
start=0
end=$NSTEPS
filename='nucl_dyn'

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

echo "Path to directory with exact data"
read ex_dir

#Loop over the RPE files
for ((i = 0 ; i <= $end ; i++)); do
  if [ $i -lt 10 ]
  then
     QSTEP='0000'$i
     STEP='000'$i
  elif [ $i -ge 10 -a $i -lt 100 ]
  then
     QSTEP='000'$i
     STEP='00'$i
  elif [ $i -ge 100 -a $i -lt 1000 ]
  then
     QSTEP='00'$i
     STEP='0'$i
  elif [ $i -ge 10000 ]
  then
     QSTEP='0'$i
     STEP=''$i
  fi
  densfile=$ex_dir'/./n_wp/n_wp.'$QSTEP'.dat'
  datafile='./trajectories/RPE.'$STEP'.dat'
  output='movie/plot_'$STEP'.gif'
    
echo "Plotting $i"

#gnuplot file
{
cat <<-EOF

set terminal gif
set out '$output'

set title "Density vs trajectories"
unset colorbox
set cbr [0:0.002]
set cbtics 0,0.001,0.002
set yr [-50:50]
set ytics -40,20,40
set yl "Position (bohr)"
set xr[-100:100]
set xtics -100,50,100
set xl "Position (bohr)"
set pm3d map
set palette defined (0 "white", 0.001 "#66B2FF", 0.0025 "#0066CC")
sp '$densfile' u 1:2:(\$3+\$4) w pm3d, \
   '$datafile' u 1:2:(0) w p pt 6 ps 0.5 lc rgb "black" t ''

EOF
} > plot.gp
gnuplot plot.gp

done

rm plot.gp

#Create animated gif
convert movie/*.gif  $filename.gif
rm -r movie
