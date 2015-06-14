# Physical Layer
Phy/WirelessPhy set freq_ 5.180e9;          # Channel 36

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

if { $single_sensitivity == 1 } {
	Phy/WirelessPhy set RXThresh0 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh1 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh2 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh3 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh4 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh5 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh6 6.3096e-10; #-92db
	Phy/WirelessPhy set RXThresh7 6.3096e-10; #-92db
} else {
	Phy/WirelessPhy set RXThresh0 3.28984e-09; #-84.8db
	Phy/WirelessPhy set RXThresh1 1.3096e-09;  # ??db
	Phy/WirelessPhy set RXThresh2 9.3096e-10;  # ??db
	Phy/WirelessPhy set RXThresh3 6.3096e-10;  #-92db
	Phy/WirelessPhy set RXThresh4 6.3096e-10;  #-92db
	Phy/WirelessPhy set RXThresh5 6.3096e-10;  #-92db
	Phy/WirelessPhy set RXThresh6 6.3096e-10;  #-92db
	Phy/WirelessPhy set RXThresh7 6.3096e-10;  #-92db
}

# Mac Layer
Mac/802_11 set dataRate_ 6Mb
Mac/802_11 set basicRate_ 6Mb
