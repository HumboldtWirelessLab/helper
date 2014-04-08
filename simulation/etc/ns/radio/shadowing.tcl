# Propagation model
# first set values of shadowing model
Propagation/Shadowing set pathlossExp_ 2.0    ;# path loss exponent
Propagation/Shadowing set std_db_ 2.0         ;# shadowing deviation (dB)
Propagation/Shadowing set dist0_ 1.0          ;# reference distance (m)
Propagation/Shadowing set seed_ 0             ;# seed for RNG
Propagation/Shadowing set nonodes_ $nodecount ;# set node count for shadowing cache

#Propagation/Shadowing set pathlossExp_ 3.0  ;# path loss exponent
#Propagation/Shadowing set std_db_ 5.0       ;# shadowing deviation (dB)
#Propagation/Shadowing set dist0_ 1.0        ;# reference distance (m)
#Propagation/Shadowing set seed_ 0           ;# seed for RNG

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set netchan     Channel/WirelessChannel
set netphy      Phy/WirelessPhy
set netmac      Mac/802_11
set netprop     Propagation/Shadowing
set antenna     Antenna/OmniAntenna
