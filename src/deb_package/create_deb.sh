#!/bin/bash

# source, target, name, architecture, depencies, folder name

fpm -s dir -t deb -n brn-tools -a all \
-d g++ \
-d autoconf \
-d libx11-dev \
-d libxt-dev \
-d libxmu-dev \
-d flex \
-d bison \
-d bc \
-d wget \
brn-tools
