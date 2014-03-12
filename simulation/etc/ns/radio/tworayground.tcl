#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set netchan     Channel/WirelessChannel
set netphy      Phy/WirelessPhy
set netmac      Mac/802_11
set netprop     Propagation/TwoRayGround
set antenna     Antenna/OmniAntenna
