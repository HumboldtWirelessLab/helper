#!/bin/sh

../MPlayer-1.0rc4/mencoder -tv driver=v4l2:device=/dev/$1 -nosound -vf tracker=$FILENAME.log -ovc lavc -o $FILENAME.mp4 tv://
#../MPlayer-1.0rc4/mencoder -tv driver=v4l2:width=640:height=480:device=/dev/video0 -fps 30 -nosound -vf tracker=foo.log -ovc lavc -o test.mp4 tv://

