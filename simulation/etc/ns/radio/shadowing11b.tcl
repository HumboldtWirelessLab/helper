# Propagation model
# first set values of shadowing model
Propagation/Shadowing set pathlossExp_ 2.0  ;# path loss exponent
Propagation/Shadowing set std_db_ 4.0       ;# shadowing deviation (dB)
Propagation/Shadowing set dist0_ 1.0        ;# reference distance (m)
Propagation/Shadowing set seed_ 0           ;# seed for RNG

# Mac Layer
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set basicRate_ 1Mb 
Mac/802_11 set RTSThreshold_ 3000

# Physical Layer
# transmission power
Phy/WirelessPhy set Pt_ 0.281838

# for broadcast packets
# channel-13.2.472GHz
Phy/WirelessPhy set freq_ 2.472e9 

# communication radius
Phy/WirelessPhy set RXThresh_ 3.28984e-09

#
# Set some general simulation parameters
#

#
# Unity gain, omnidirectional antennas, centered 1.5m above each node.
# These values are lifted from the ns-2 sample files.
#
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# 
# Set the size of the playing field and the topography.
#
