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

# Physical Layer

Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 3.1623e-10;    #-95db
Phy/WirelessPhy set RXThresh_ 3.28984e-09;   #-84.8db communication radius
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.281838;            # transmission power
Phy/WirelessPhy set freq_ 2.472e9;           # for broadcast packets channel-13.2.472GHz
Phy/WirelessPhy set L_ 1.0

# Configure multirate aspect
Phy/WirelessPhy set RateCount_ 8
Phy/WirelessPhy set Rate0 54e6
Phy/WirelessPhy set Rate1 48e6
Phy/WirelessPhy set Rate2 36e6
Phy/WirelessPhy set Rate3 24e6
Phy/WirelessPhy set Rate4 18e6
Phy/WirelessPhy set Rate5 12e6
Phy/WirelessPhy set Rate6 9e6
Phy/WirelessPhy set Rate7 6e6
Phy/WirelessPhy set RXThresh0 3.28984e-09; #-84.8db
Phy/WirelessPhy set RXThresh1 1.3096e-09; # ??db
Phy/WirelessPhy set RXThresh2 9.3096e-10; # ??db
Phy/WirelessPhy set RXThresh3 6.3096e-10; #-92db
Phy/WirelessPhy set RXThresh4 6.3096e-10; #-92db
Phy/WirelessPhy set RXThresh5 6.3096e-10; #-92db
Phy/WirelessPhy set RXThresh6 6.3096e-10; #-92db
Phy/WirelessPhy set RXThresh7 6.3096e-10; #-92db

# Mac Layer
Mac/802_11 set dataRate_ 6Mb
Mac/802_11 set basicRate_ 6Mb
Mac/802_11 set RTSThreshold_ 0
Mac/802_11 set ShortRetryLimit_ 0
Mac/802_11 set LongRetryLimit_ 0

Mac/802_11 set TXFeedback_ 1
Mac/802_11 set Promisc_ 1
Mac/802_11 set FilterDub_ 0
Mac/802_11 set ControlFrames_ 1

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set netchan	Channel/WirelessChannel
set netphy	Phy/WirelessPhy
set netmac	Mac/802_11
set antenna     Antenna/OmniAntenna

#set netprop     Propagation/Shadowing
#set netprop     Propagation/TwoRayGround
