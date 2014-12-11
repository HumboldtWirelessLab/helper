#
# Stop the simulation
#
$ns_ at  $stoptime.000000001 "puts \"NS EXITING...\" ; $ns_ halt"

#
# Let nam know that the simulation is done.
#
$ns_ at  $stoptime	"$ns_ nam-end-wireless $stoptime"


puts "Starting Simulation..."
puts "#Nodes: $nodecount"
puts "Duration: $stoptime s"
puts "Pathloss: $channel_model"
puts "Shadowing-Pathloss: $shadowing_channel_model"
puts "Fading: $fading_model"
puts "Scheduler: $ns_scheduler"
puts ""
puts "Starting Simulation..."
puts ""

$ns_ run



