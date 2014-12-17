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
# Phy, Mac, ... stuff for 802.11a and 802.11bg
#

# Physical Layer

#JIST
#Noise        1.0286620123018115E-10  #-99.87  
#CCA          2.511886431509582E-10   #-96     //Sensitivity_mW
#RXThreshold  3.1622776601683795E-10  #-95     //threshold_mw

Phy/WirelessPhy set CPThresh_   10.0;          #10db
Phy/WirelessPhy set Noise_    -100.0;
Phy/WirelessPhy set CSThresh_  -96.0;
Phy/WirelessPhy set RXThresh_  -95.0;
#Old NS2
#Phy/WirelessPhy set CSThresh_ 6.3096e-10;      #-92db
#Phy/WirelessPhy set RXThresh_ 3.1623e-10;      #-95db if madwifi (extra header) is used, then rxtresh is used as noise

#Phy/WirelessPhy set CSThresh_ 3.1623e-10;     #-95db
#Phy/WirelessPhy set RXThresh_ 6.3096e-10;     #-92db  communication radius

Phy/WirelessPhy set Pt_   24;                  # transmission power (24dbm = 0.25118 watt)
Phy/WirelessPhy set L_    1.0;


Mac/802_11 set RTSThreshold_ 0
Mac/802_11 set ShortRetryLimit_ 0
Mac/802_11 set LongRetryLimit_ 0

Mac/802_11 set TXFeedback_ 1
Mac/802_11 set Promisc_ 1
Mac/802_11 set FilterDub_ 0
Mac/802_11 set ControlFrames_ 1

Mac/802_11 set MadwifiTPC_ 0

Propagation/Shadowing set pathlossExp_ $shadowing_pl_exp      ;# path loss exponent
Propagation/Shadowing set init_std_db_ $shadowing_init_std_db ;# initial shadowing deviation (dB) taken at start time for hole sim
Propagation/Shadowing set std_db_      $shadowing_std_db      ;# shadowing deviation (dB)
Propagation/Shadowing set dist0_       $shadowing_dist0       ;# reference distance (m)
Propagation/Shadowing set seed_        $shadowing_seed        ;# seed for RNG
Propagation/Shadowing set nonodes_     $nodecount             ;# set node count for shadowing cache


# first set values of Nakagami model
# Params tken from Paper "Influences of TwoRayGround and Nakagami Propagation model for the Performance of Adhoc Routing Protocol in VANET"

Propagation/Nakagami set use_nakagami_dist_ $nakagami_use_dist

Propagation/Nakagami set gamma0_ $nakagami_gamma0
Propagation/Nakagami set gamma1_ $nakagami_gamma1
Propagation/Nakagami set gamma2_ $nakagami_gamma2

Propagation/Nakagami set d0_gamma_ $nakagami_d0_gamma
Propagation/Nakagami set d1_gamma_ $nakagami_d1_gamma

Propagation/Nakagami set m0_ $nakagami_m0
Propagation/Nakagami set m1_ $nakagami_m1
Propagation/Nakagami set m2_ $nakagami_m2

Propagation/Nakagami set d0_m_ $nakagami_d0
Propagation/Nakagami set d1_m_ $nakagami_d1

Fading/Rayleigh set seed_      $shadowing_seed        ;# seed for RNG

#
# The network channel, physical layer, MAC, propagation model,
# and antenna model are all standard ns-2.
#
set netchan	 Channel/WirelessChannel
set antenna  Antenna/OmniAntenna
set netphy	 Phy/WirelessPhy

if { ! [info exists channel_model] } {
	set channel_model "tworayground";
}

if { ! [info exists shadowing_channel_model] } {
	set shadowing_channel_model "default";
}

if { ! [info exists fading_model] } {
	set fading_model "none";
}
	
switch $channel_model {
	"freespace" {
			set netprop     Propagation/FreeSpace
		}
	"tworayground" {
			set netprop     Propagation/TwoRayGround
		}
	"nakagami" {
			set netprop     Propagation/Nakagami
		}
	"shadowing" {
			set netprop     Propagation/Shadowing

			switch $shadowing_channel_model {
				"freespace" {
						set shadowing_netprop     [new Propagation/FreeSpace]
					}
				"tworayground" {
						set shadowing_netprop     [new Propagation/TwoRayGround]
					}
				default {
					puts "Unknown SHADOWING_PATHLOSS_MODEL! use default (Freespace)"
					set shadowing_netprop     [new Propagation/FreeSpace]
				}
			}			
		}
}

switch $fading_model {
	"ricean" {
			set netfading     Fading/Ricean
		}
	"rayleigh" {
			set netfading     Fading/Rayleigh
		}
	 default {
			set netfading     Fading/None
   }		 
}

set netmac	 Mac/802_11

set wtopo	   [new Topography]
$wtopo load_flatgrid $xsize $ysize

#
# We have to use a special queue and link layer. This is so that
# Click can have control over the network interface packet queue,
# which is vital if we want to play with, e.g. QoS algorithms.
#
set netifq	Queue/ClickQueue
set netll	LL/Ext

LL set delay_			0ms;

#
# Standard ns-2 stuff here - create the simulator object.
#
if { $enable_trace == 1 } {
  Simulator set MacTrace_ ON
} else {
  Simulator set MacTrace_ OFF
}

#
# PacketHeader
#
PacketHeaderManager set hdrlen_ 0
PacketHeaderManager set clear_packet_ 0

# XXX Common header should ALWAYS be present
PacketHeaderManager set tab_(Common) 1

remove-all-packet-headers
add-packet-header Raw IP TCP Mac LL ARP

#
# new Simulator
#
set ns_		[new Simulator]

if { ! [info exists ns_scheduler] } {
	set ns_scheduler "heap";
}

switch $ns_scheduler {
	"calender" {
		  Scheduler/Calendar set adjust_new_width_interval_ 10;	# the interval (in unit of resize times) we recalculate bin width. 0 means disable dynamic adjustment
      Scheduler/Calendar set min_bin_width_ 1e-21;		# the lower bound for the bin_width
      $ns_ use-scheduler Calendar
    }
	"heap" {
      $ns_ use-scheduler Heap
    }
	"list" {
      $ns_ use-scheduler List
    }
	"map" {
      $ns_ use-scheduler Map
    }
	"realtime" {
      $ns_ use-scheduler RealTime
    }
}  

#
# Create and activate trace files.
#
if { $enable_tr == 1 } {
  set tracefd     [open $trfilename w]
} else {
  set tracefd     [open "/dev/null" w]
}

$ns_ trace-all $tracefd

if { $enable_nam == 1 } {
  set namtrace    [open $namfilename w]
} else {
  set namtrace    [open "/dev/null" w]
}

$ns_ namtrace-all-wireless $namtrace $xsize $ysize
$ns_ use-newtrace

#
# Create the "god" object. This is another artifact of using
# the mobile node type. We have to have this even though
# we never use it.
#
set god_ [create-god $nodecount]

#
# Tell the simulator to create Click nodes.
#
Simulator set node_factory_ Node/MobileNode/ClickNode

#
# Create a network Channel for the nodes to use. One channel
# per LAN. Also set the propagation model to be used.
#
set chan_ [new $netchan]
set prop_ [new $netprop]

switch $channel_model {
	"shadowing" {
		if { $shadowing_channel_model != "default" } {
			$prop_ propagation $shadowing_netprop
    }
  }
}


set fading_ [new $netfading]

if { $fading_model == "ricean" } {
  $fading_ MaxVelocity   $ricean_max_velocity;
  $fading_ RiceanK       $ricean_k;
  $fading_ LoadRiceFile  $brntoolsbase/helper/simulation/etc/ns/radio/rice_table.txt;
}

# We set the routing protocol to "Empty" so that ns-2 doesn't do
# any packet routing. All of the routing will be done by the
# Click script.
#
$ns_ rtproto Empty

#
# Here is where we actually create all of the nodes.
#
for {set i 0} {$i < $nodecount } {incr i} {
    set node_($i) [$ns_ node]

    #
    # After creating the node, we add one wireless network interface to
    # it. By default, this interface will be named "eth0". If we
    # added a second interface it would be named "eth1", a third
    # "eth2" and so on.
    #
    $node_($i) add-interface $chan_ $prop_ $netll $netmac $netifq 1 $netphy $antenna $wtopo $fading_

    #
    # Now configure the interface eth0
    #
    #  mac and ip is set by run_sim.sh
    #
    #$node_($i) setip "eth0" $node_ip($i)
    $node_($i) setmac "eth0" $node_mac($i)

    #
    # Set some node properties
    #
    $node_($i) random-motion 0
    $node_($i) topography $wtopo
    $node_($i) nodetrace $tracefd

    $node_($i) set X_ $pos_x($i)
    $node_($i) set Y_ $pos_y($i)
    $node_($i) set Z_ $pos_z($i)
    $node_($i) label $nodelabel($i)

    #
    # The node name is used by Click to distinguish information
    # coming from different nodes. For example, a "Print" element
    # prepends this to the printed string so it's clear exactly
    # which node is doing the printing.
    #
    # NODENAME is set by run_sim.sh
    #
    [$node_($i) set classifier_] setnodename $node_name($i)

    [$node_($i) entry] packetzerocopy false

    [$node_($i) entry] loadclick $clickfile($i)

    #
    # Load the appropriate Click router script for the node.
    # All nodes in this simulation are using the same script,
    # but there's no reason why each node couldn't use a different
    # script.
    #
    $ns_ at 0.0 "[$node_($i) entry] runclick"

    #
    # This sizes the nodes for use in nam. Currently, the trace files
    # produced by nsclick don't really work in nam.
    #
    $ns_ initial_node_pos $node_($i) 20
}

# 
# Define node network traffic. There isn't a whole lot going on
# in this simple test case, we're just going to have the first node
# send packets to the last node, starting at 1 second, and ending at 10.
# There are Perl scripts available to automatically generate network
# traffic.
#

#
# With nsclick, we have to worry about details like which network
# port to use for communication. This sets the default ports to 5000.
#
Agent/Null set sport_		5000
Agent/Null set dport_		5000

Agent/CBR set sport_		5000
Agent/CBR set dport_		5000

#
# Start transmitting at $startxmittime, $xmitrate packets per second.
#
set startxmittime 0
set xmitrate 4
set xmitinterval 0.25
set packetsize 64
