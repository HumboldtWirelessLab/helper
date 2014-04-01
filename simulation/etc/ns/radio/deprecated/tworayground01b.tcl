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
# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
# These are taken directly from the ns-2 sample files.
#

##FHSS (IEEE802.11)

#CaptureTreshold (CPTresh) in db
Phy/WirelessPhy set CPThresh_ 10.0
#Phy/WirelessPhy set CSThresh_ 1.559e-11
#Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set CSThresh_ 3.1623e-10; #-95db
Phy/WirelessPhy set RXThresh_ 6.3096e-10; #-92db
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 2.472e9
Phy/WirelessPhy set L_ 1.0
Phy/WirelessPhy set bandwidth_ 1Mb

Mac/802_11 set SlotTime_          0.000050        ;# 50us
Mac/802_11 set SIFS_              0.000028        ;# 28us
Mac/802_11 set PreambleLength_    0               ;# no preamble
Mac/802_11 set PLCPHeaderLength_  128             ;# 128 bits
Mac/802_11 set PLCPDataRate_      1.0e6           ;# 1Mbps
Mac/802_11 set dataRate_          1.0e6           ;# 11Mbps
Mac/802_11 set basicRate_         1.0e6           ;# 1Mbps

Mac/802_11 set RTSThreshold_ 3000
Mac/802_11 set ShortRetryLimit_ 7               ;# retransmittions
Mac/802_11 set LongRetryLimit_  4               ;# retransmissions
Mac/802_11 set TXFeedback_ 1
Mac/802_11 set Promisc_ 1
Mac/802_11 set FilterDub_ 0
Mac/802_11 set ControlFrames_ 1
Mac/802_11 set ShortRetryLimit_ 0
Mac/802_11 set LongRetryLimit_ 0

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#  
set netchan	Channel/WirelessChannel
set netphy	Phy/WirelessPhy
set netmac	Mac/802_11
set netprop     Propagation/TwoRayGround
set antenna     Antenna/OmniAntenna
