#!/bin/bash

for chan in 1 2 3 4 5 6 7 8 9 10 11 12 13 36 40 44 48 52 56 60 64; do
    ssh brn-suse093-7 "mkdir tmp"
    cp *.m /home/sombrutz/lab/measurement_final/measurement_002/channel_$chan/
    (cd /home/sombrutz/lab/measurement_final/measurement_002/channel_$chan/;scp *.dat *.m brn-suse093-7:tmp)
    ssh brn-suse093-7 "cd tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"rssi_per_all;exit\""
    (cd /home/sombrutz/lab/measurement_final/measurement_002/channel_$chan/;scp brn-suse093-7:tmp/*.png .)
    (cd /home/sombrutz/lab/measurement_final/measurement_002/channel_$chan/;scp brn-suse093-7:tmp/*.eps .)
    ssh brn-suse093-7 "rm -rf tmp"

done
exit 0
