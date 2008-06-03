#!/bin/bash

(cd $1; ~/lab/helper/evaluation/rssi_per-003/evaluation.sh )
ssh brn-suse093-7 "mkdir tmp"
(cd ~/lab/helper/evaluation/rssi_per-003/;cp *.m $1 )
(cd $1;scp *.dat *.m brn-suse093-7:tmp)
ssh brn-suse093-7 "cd tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"rssi_per_all;exit\""
(cd $2;scp brn-suse093-7:tmp/*.png .)
ssh brn-suse093-7 "rm -rf tmp"

exit 0
