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
  output='movie/plot_'$STEP'.gif'
  densityfile='./n_wp/n_wp.'$STEP'.dat'
  
echo "0 0" > CI.dat
    
echo "Plotting $i"

#gnuplot file
{
cat <<-EOF

set terminal gif
set out '$output'

NX=1; NY=2
DX=0.1; DY=0.1; SX=0.8; SY=0.45
set bmargin DX; set tmargin DX; set lmargin DY; set rmargin DY
set size SX*NX+DX,SY*NY+DY
set multiplot

set style line 1 lt 1 lw 1 pt 7 ps 0.75 linecolor rgb "gray"

set size SX,SY
set origin DX,DY+SY;
set title "Excited state density"
set colorbox
set cbr [0:0.002]
set cbtics 0,0.001,0.002
set yr [-50:50]
set ytics -40,20,40
set yl "Position (bohr)"
set xr[-100:100]
set xtics -100,50,100
set xl ""
set pm3d map
set palette defined (0 "white", 0.001 "#66B2FF", 0.0025 "#0066CC")
sp '$densityfile' u 1:2:4 w pm3d, 'CI.dat' u 1:2:(0) w p lw 5 pt 7 lc rgb "black" t ''
set size SX,SY
set origin DX,DY;
set title "Ground state density"
set colorbox
set cbr [0:0.002]
set cbtics 0,0.001,0.002
set yr [-50:50]
set ytics -40,20,40
set yl "Position (bohr)"
set xr[-100:100]
set xtics -100,50,100
set xl "Position (bohr)"
set pm3d map
sp '$densityfile' u 1:2:3 w pm3d, 'CI.dat' u 1:2:(0) w p lw 5 pt 7 lc rgb "black" t ''


set size SX,SY
set nokey
set origin DX,DY+SY;
set title ""
unset colorbox
set yr [-50:50]
set ytics (""-40,""-20,""0,""20,""40)
set yl ""
set xr[-150:150]
set xtics (""-150,""-100,""-50,""0,""50,""100,""150)
set xl ""
unset clabel
set pm3d map
set contour base
set cntrparam levels incremental 0,0.02,1.2
set nosurface
sp "BO_energy.dat" u 1:2:7 w l ls 1
set size SX,SY
set nokey
set origin DX,DY;
set title ""  font ",10"
unset colorbox
set yr [-50:50]
set ytics (""-40,""-20,""0,""20,""40)
set yl ""
set xr[-150:150]
set xtics (""-150,""-100,""-50,""0,""50,""100,""150)
set xl ""
unset clabel
set pm3d map
set contour base
set cntrparam levels incremental 0,0.02,1.2
set nosurface
sp "BO_energy.dat" u 1:2:6 w l ls 1

EOF
} > plot.gp
gnuplot plot.gp

done

rm plot.gp
rm CI.dat

#Create animated gif
convert movie/*.gif  $filename.gif
rm -r movie
