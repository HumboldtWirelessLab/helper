

set wtopo	[new Topography]
$wtopo load_flatgrid $xsize $ysize

#
# We have to use a special queue and link layer. This is so that
# Click can have control over the network interface packet queue,
# which is vital if we want to play with, e.g. QoS algorithms.
#
set netifq	Queue/ClickQueue
set netll	LL/Ext
#LL set delay_			1ms
LL set delay_			0ms

#
# With nsclick, we have to worry about details like which network
# port to use for communication. This sets the default ports to 5000.
#
Agent/Null set sport_		5000
Agent/Null set dport_		5000

Agent/CBR set sport_		5000
Agent/CBR set dport_		5000

#
# Standard ns-2 stuff here - create the simulator object.
#
if { $enable_trace == 1 } {
  Simulator set MacTrace_ ON
} else {
  Simulator set MacTrace_ OFF
}

PacketHeaderManager set hdrlen_ 0
PacketHeaderManager set clear_packet_ 0

# XXX Common header should ALWAYS be present
PacketHeaderManager set tab_(Common) 1

remove-all-packet-headers
add-packet-header Raw IP TCP Mac LL ARP

set ns_		[new Simulator]

Scheduler/Calendar set adjust_new_width_interval_ 10;	# the interval (in unit of resize times) we recalculate bin width. 0 means disable dynamic adjustment
Scheduler/Calendar set min_bin_width_ 1e-21;		# the lower bound for the bin_width
#$ns_ use-scheduler Calendar
$ns_ use-scheduler Heap
#$ns_ use-scheduler List
#$ns_ use-scheduler Map
#$ns_ use-scheduler RealTime
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
set chan_1_ [new $netchan]
set prop_ [new $netprop]

#
# In nsclick we have to worry about assigning IP and MAC addresses
# to out network interfaces. Here we generate a list of IP and MAC
# addresses, one per node since we've only got one network interface
# per node in this case. Also note that this scheme only works for
# fewer than 255 nodes, and we aren't worrying about subnet masks.
#

#set iptemplate "10.0.%d.%d"
#set mactemplate "00:00:00:00:%0x:%0x"
#for {set i 0} {$i < $nodecount} {incr i} {
#    set node_ip($i) [format $iptemplate [expr ($i+1)/256] [expr ($i+1)%256] ]
#    set node_mac($i) [format $mactemplate [expr ($i+1)/256] [expr ($i+1)%256] ]
#}

#
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
    $node_($i) add-interface $chan_1_ $prop_ $netll $netmac $netifq 1 $netphy $antenna $wtopo

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
}

# 
# Define node network traffic. There isn't a whole lot going on
# in this simple test case, we're just going to have the first node
# send packets to the last node, starting at 1 second, and ending at 10.
# There are Perl scripts available to automatically generate network
# traffic.
#


#
# Start transmitting at $startxmittime, $xmitrate packets per second.
#
set startxmittime 0
set xmitrate 4
set xmitinterval 0.25
set packetsize 64

#
# This sizes the nodes for use in nam. Currently, the trace files
# produced by nsclick don't really work in nam.
#
for {set i 0} {$i < $nodecount} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}
