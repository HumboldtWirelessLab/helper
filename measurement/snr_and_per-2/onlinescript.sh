#!/bin/sh

DIRNAME=`echo $2 | sed -e "s#/##g"`
NAME=`echo $3 | sed -e "s#/##g"`


ssh sombrutz@star.informatik.hu-berlin.de "mkdir ~/Docs/website/testbed/$DIRNAME"
ssh sombrutz@star.informatik.hu-berlin.de "mkdir ~/Docs/website/testbed/$DIRNAME/$NAME"
(cd $1;scp * sombrutz@star.informatik.hu-berlin.de:~/Docs/website/testbed/$DIRNAME/$NAME/)
(cd $1;rm *)

exit 0
