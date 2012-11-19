#!/bin/sh
# ------------ Test Input -------------------------------
if [ "$#" -ge 2 ] ; then
    if [ "$#" -eq 2 ] ; then
        script_matlab="$1"
        use_server="$2" # if server is used set this variable to 1
        use_display="-1" #if display is not needed, set this variable to 0
        directory_matlab="-1"
    else 
        if [ "$#" -eq 3 ] ; then
            script_matlab="$1"
            use_server="$2" # if server is used set this variable to 1
            use_display="$3" #if display is not needed, set this variable to 0
            directory_matlab="-1"
        else
            if [ "$#" -ge 4 ] ; then
                script_matlab="$1"
                use_server="$2" # if server is used set this variable to 1
                use_display="$3" #if display is not needed, set this variable to 0
                directory_matlab="$4"
            else
                echo "Usage: Please do the following comand:"
                echo "./run_matlab.sh [Name of the Matlab script] [Use Server or locol machine] [Display graphics] [Path to your Matlab programm]"
                exit 1
            fi
        fi
    fi
else
    echo "Usage: Please do the following comand:"
    echo "./run_matlab.sh [Name of the Matlab script] [Use Server or locol machine] [Display graphics] [Path to your Matlab programm]"
    echo " "
    echo "If you use the server (e.g. gruenau) do the following command:"
    echo "./run_matlab.sh [Name of the Matlab script] 1"
    echo " "
    echo "If you use your local pc do the following command:"
    echo "./run_matlab.sh [Name of the Matlab script] 0"
    echo " "
    echo "If you will not see the plots do the following command:"
    echo "./run_matlab.sh [Name of the Matlab script] 0 0"
    echo " "
    echo "If you will see the plots do the following command:"
    echo "./run_matlab.sh [Name of the Matlab script] 0 1"
    exit 1
fi

#--------------  Start Script ---------------------------
directory_current=$PWD
echo "$directory_matlab"
if [ "$use_server" -eq 0 ]; then
    if [ "$directory_matlab" != "-1" ]; then
        cd $directory_matlab
        echo "$directory_matlab"
    fi
    if [ "$use_display" -eq 1 ]; then
    ./matlab -nodesktop -nosplash -r "cd('$directory_current');run $script_matlab;while(waitforbuttonpress ~= 1) end;exit"
    else
    ./matlab -nodesktop -nosplash -nodisplay -r "cd('$directory_current');run $script_matlab;exit"
    fi
else
    matlab -nodesktop -nosplash -nodisplay -r "cd('$directory_current');run $script_matlab;exit"
fi

