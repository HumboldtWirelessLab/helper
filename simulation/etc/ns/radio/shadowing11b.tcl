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

# Propagation model
# first set values of shadowing model
Propagation/Shadowing set pathlossExp_ 2.0  ;# path loss exponent
Propagation/Shadowing set std_db_ 4.0       ;# shadowing deviation (dB)
Propagation/Shadowing set dist0_ 1.0        ;# reference distance (m)
Propagation/Shadowing set seed_ 0           ;# seed for RNG

# Physical Layer
Phy/WirelessPhy set Pt_ 0.281838     ;# transmission power
Phy/WirelessPhy set freq_ 2.472e9    ;# for broadcast packets channel-13.2.472GHz
Phy/WirelessPhy set RXThresh_ 3.28984e-09   ;# communication radius

# Mac Layer
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set basicRate_ 1Mb 
Mac/802_11 set RTSThreshold_ 3000
Mac/802_11 set TXFeedback_ 1
Mac/802_11 set Promisc_ 1

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#  
set netchan	Channel/WirelessChannel
set netphy	Phy/WirelessPhy
set netmac	Mac/802_11
set netprop     Propagation/Shadowing
set antenna     Antenna/OmniAntenna

