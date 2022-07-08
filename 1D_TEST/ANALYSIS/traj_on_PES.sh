#!/bin/bash

function usage() {
    cat <<EOF

    Copyright (C) 2022 by Federica Agostini
    traj_on_PES.sh
    
     -h         Print usage
     -i         Index of the trajectory 
     
    Report to <federica.agostini@universite-paris-saclay.fr>.

EOF
  exit 0;
}

# Default:
ITRAJ=1

while getopts "hi:" arg ; do
    case "$arg" in
	h) usage ;;
	i) ITRAJ=${OPTARG} ;;
    esac
done

# If no argument:
[ "$#" -eq 0 ] && usage;

# Check if the given trajectory label is ok
TMP_STRING=`wc -l trajectories/RPE.0000.dat | awk '{print $1}'`
TMP=$((TMP_STRING))
UNO=1
NTRAJ=`expr $TMP - $UNO`
if [ $ITRAJ -gt $NTRAJ ]
then
   echo "The label of the trajectory is too large"
fi

#Number of steps
TMP_STRING=`ls -l trajectories/RPE.*.dat | wc -l`
TMP=$((TMP_STRING))
NSTEPS=`expr $TMP - $UNO`

#Loop over the RPE files
for ((i = 0 ; i <= $NSTEPS ; i++)); do
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
  filename='./trajectories/RPE.'$STEP'.dat'
  line=`expr $ITRAJ + $UNO`
  #echo $filename $line
  head '-'$line $filename | tail -1 >> 'TRAJ_'$ITRAJ'_ON_PES.dat'
done

filename='TRAJ_'$ITRAJ'_ON_PES.ps'
datafile='TRAJ_'$ITRAJ'_ON_PES.dat'

#gnuplot file
{
cat <<-EOF

set terminal post col enhanced
set output '$filename'

set xr [2:30]
set yr [-0.2:0.2]
set xl "Position (bohr)"
set yl "Energy (hartree)"
p 'analytical_potential.dat' u 1:5 w l lw 4 lc rgb "red" t 'BO PES1', \
  '' u 1:6 w l lw 4 lc rgb "blue" t 'BO PES2', \
    '$datafile' u 1:3 w p pt 6 lc rgb "black" t 'TRAJECTORY'

EOF
} > plot.gp
gnuplot plot.gp
rm plot.gp

ps2pdf $filename
rm $filename
