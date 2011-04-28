#!/bin/sh

clickctrl.sh read $1 7777 device_wifi/link_stat bcast_stats | human_readable.sh
