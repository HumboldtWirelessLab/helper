#!/bin/sh

export RCX_PORT="usb" # Zieladresse 
export NQC_OPTIONS="-Trcx2"

#nqc -near -firmfast ./firm0328.lgo
nqc -firmware ./firm0328.lgo
