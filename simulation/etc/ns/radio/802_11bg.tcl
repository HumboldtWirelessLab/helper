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

#JIST
#Noise        1.0286620123018115E-10  #-99.87  
#CCA          2.511886431509582E-10   #-96     //Sensitivity_mW
#RXThreshold  3.1622776601683795E-10  #-95     //threshold_mw

Phy/WirelessPhy set CPThresh_   10.0;          #10db
Phy/WirelessPhy set Noise_    -100.0;
Phy/WirelessPhy set CSThresh_  -96.0;
Phy/WirelessPhy set RXThresh_  -95.0;

Phy/WirelessPhy set Pt_   0.25118;             # transmission power (24dbm)
Phy/WirelessPhy set freq_ 2.472e9;             # for broadcast packets channel-13.2.472GHz
Phy/WirelessPhy set L_    1.0;

#Old NS2
#Phy/WirelessPhy set CSThresh_ 6.3096e-10;      #-92db
#Phy/WirelessPhy set RXThresh_ 3.1623e-10;      #-95db if madwifi (extra header) is used, then rxtresh is used as noise

#Phy/WirelessPhy set CSThresh_ 3.1623e-10;     #-95db
#Phy/WirelessPhy set RXThresh_ 6.3096e-10;     #-92db  communication radius

# Configure multirate aspect
Phy/WirelessPhy set RateCount_ 12

Phy/WirelessPhy set Rate0   54e6
Phy/WirelessPhy set Rate1   48e6
Phy/WirelessPhy set Rate2   36e6
Phy/WirelessPhy set Rate3   24e6
Phy/WirelessPhy set Rate4   18e6
Phy/WirelessPhy set Rate5   12e6
Phy/WirelessPhy set Rate6   11e6
Phy/WirelessPhy set Rate7    9e6
Phy/WirelessPhy set Rate8    6e6
Phy/WirelessPhy set Rate9  5.5e6
Phy/WirelessPhy set Rate10   2e6
Phy/WirelessPhy set Rate11   1e6

Phy/WirelessPhy set RXThresh0  30;
Phy/WirelessPhy set RXThresh1  28;
Phy/WirelessPhy set RXThresh2  24;
Phy/WirelessPhy set RXThresh3  21;
Phy/WirelessPhy set RXThresh4  19;
Phy/WirelessPhy set RXThresh5  15;
Phy/WirelessPhy set RXThresh6  13; #6.3096e-9  -82dbm //-95dbm Noise
Phy/WirelessPhy set RXThresh7  12;
Phy/WirelessPhy set RXThresh8  12;
Phy/WirelessPhy set RXThresh9   9; #2.5119e-9  -86dbm //-95dbm Noise
Phy/WirelessPhy set RXThresh10  8; #1.9953e-9  -87dbm //-95dbm Noise
Phy/WirelessPhy set RXThresh11  7; #1.5849e-9  -88dbm //-95dbm Noise

# Mac Layer
Mac/802_11 set dataRate_  1Mb
Mac/802_11 set basicRate_ 1Mb

Mac/802_11 set RTSThreshold_    0
Mac/802_11 set ShortRetryLimit_ 0
Mac/802_11 set LongRetryLimit_  0

Mac/802_11 set TXFeedback_    1
Mac/802_11 set Promisc_       1
Mac/802_11 set FilterDub_     0
Mac/802_11 set ControlFrames_ 1
