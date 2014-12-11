# Physical Layer
Phy/WirelessPhy set freq_ 2.472e9;             # for broadcast packets channel-13.2.472GHz

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

if { $single_sensitivity == 1 } {
	Phy/WirelessPhy set RXThresh0   7;
	Phy/WirelessPhy set RXThresh1   7;
	Phy/WirelessPhy set RXThresh2   7;
	Phy/WirelessPhy set RXThresh3   7;
	Phy/WirelessPhy set RXThresh4   7;
	Phy/WirelessPhy set RXThresh5   7;
	Phy/WirelessPhy set RXThresh6   7;
	Phy/WirelessPhy set RXThresh7   7;
	Phy/WirelessPhy set RXThresh8   7;
	Phy/WirelessPhy set RXThresh9   7;
	Phy/WirelessPhy set RXThresh10  7;
	Phy/WirelessPhy set RXThresh11  7;
} else {
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
}

# Mac Layer
Mac/802_11 set dataRate_  1Mb
Mac/802_11 set basicRate_ 1Mb
