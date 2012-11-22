#!/bin/sh
echo "Configuration of Matlab script"
echo "What is the Name of your Matlab script (without .m)?"
read file_name
echo "Do you use a server (e.g. Gruenau) for the execution of your matlab files? (y/n)"
read answer_use_server
if [ "$answer_use_server" = "y" ] ; then
    use_server=1
    echo "./run_matlab.sh $file_name $use_server" > run_sim.sh
else
    use_server=0
    echo "Do you want to display the graphics/figures? (y/n)"
    read answer_display_graphics
    echo "Do you need a Matlab Path (y/n)"
    read answer_path

    if [ "$answer_display_graphics" = "y" ] ; then
        display_graphics=1
    else
        display_graphics=0
    fi
    if [ "$answer_path" = "y" ] ; then
        echo "What is your path to Matlab?"
        read matlab_path
        echo "./run_matlab.sh $file_name $use_server $display_graphics $matlab_path" >  run_sim.sh
    else 
        echo "./run_matlab.sh $file_name $use_server $display_graphics"  >  run_sim.sh 

    fi
fi
chmod +x run_sim.sh

