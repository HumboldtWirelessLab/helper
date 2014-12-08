# Propagation model
# first set values of Nakagami model
# Params tken from Paper "Influences of TwoRayGround and Nakagami Propagation model for the Performance of Adhoc Routing Protocol in VANET"

Propagation/Nakagami set use_nakagami_dist_ true

Propagation/Nakagami set gamma0_ 2.0
Propagation/Nakagami set gamma1_ 2.0
Propagation/Nakagami set gamma2_ 2.0

Propagation/Nakagami set d0_gamma_ 200
Propagation/Nakagami set d1_gamma_ 500

Propagation/Nakagami set m0_ 1.0
Propagation/Nakagami set m1_ 1.0
Propagation/Nakagami set m2_ 1.0

Propagation/Nakagami set d0_m_ 80
Propagation/Nakagami set d1_m_ 200

# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set netchan     Channel/WirelessChannel
set netphy      Phy/WirelessPhy
set netmac      Mac/802_11
set netprop     Propagation/Nakagami
set antenna     Antenna/OmniAntenna

set channel_model "nakagami"
