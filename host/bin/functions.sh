#!/bin/sh

node_available() {
    AVAILABLE=`LANG=C ping -c 1 $1 2>&1 | grep "transmitted" | awk '{print $4}'`
    if [ "$AVAILABLE" = "1" ]; then
	echo "y"
    else
        echo "n"
    fi
}

run_on_node() {
    ssh -i $4 root@$1 "(cd $3;$2)"
}

get_arch() {
     ARCH=`run_on_node $1 "uname -m" "/" $2`
     echo "$ARCH"
}
