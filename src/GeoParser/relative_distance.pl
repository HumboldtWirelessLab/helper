#!/bin/bin/perl
# autor: chris ricardo
# email: kuehne@informatik.hu-berlin.de
# task: this prog calculates the relative coordinates (x,y,z) to a base point 

use DBI;
my $database = "hwl";
my $username = "hwl_user";
my $password = "testbed";
my $hostname = "192.168.4.164";
my $db = DBI->connect("DBI:mysql:$database:$hostname", $username, $password );

$refpoint_name = "wgt55";
my $sql_query = "select latitude,longitude,height,name from testbed_nodes where name='$refpoint_name'";
$query = $db->prepare($sql_query);
$execute = $query->execute;
while (@array = $query->fetchrow_array) {
	$refpoint_lat = @array[0];
	$refpoint_lon = @array[1];
	$refpoint_h = @array[2];
}
#print "Point of reference: $refpoint_name, $refpoint_lat, $refpoint_lon, $refpoint_h\n";


my $sql_query = "select latitude,longitude,height,name from testbed_nodes where latitude!=0 and longitude!=0";
$query = $db->prepare($sql_query);
$execute = $query->execute;


while (@array = $query->fetchrow_array) {
	$lat = @array[0];
	$lon = @array[1];
	$h = @array[2];
	$name = @array[3];


	# Anmerkung 1: z-Koordinate wird genordet !
	# Anmerkung 2: Bezugssystem, parametrisiert durch Bezugspunkt und variablen Punkt
	$rel_y = $h - $refpoint_h;
	$rel_z = `java GeoParser $refpoint_lat $refpoint_lon  $lat $refpoint_lon`;
	if (52.4293620000 > $lat){$rel_z = $rel_z*-1;}
	$rel_x = `java GeoParser $refpoint_lat $refpoint_lon $refpoint_lat $lon`;	
	if (13.5308670000 > $lon){ $rel_x = $rel_x*-1; }
	
	#sleep(1);
	chomp($rel_x); chomp($rel_y); chomp($rel_z);
	print "$name,$rel_x,$rel_y,$rel_z\n";

	# This updates the db with the new relative coordinates
	#my $sql2 = "update testbed_nodes set gui_3d_x='$rel_x', gui_3d_y='$rel_y', gui_3d_z='$rel_z' where name='$name' ";
	#my $query2 = $db->prepare($sql2);
	#$query2->execute;

	#print "\t$distance\n";
	$i++;
}

