#
# This sizes the nodes for use in nam. Currently, the trace files
# produced by nsclick don't really work in nam.
#
for {set i 0} {$i < $nodecount} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

