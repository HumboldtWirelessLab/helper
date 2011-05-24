#!/bin/bin/perl
# autor: chris ricardo
# email: kuehne@informatik.hu-berlin.de
# Task: this prog uses the db and the GeoParser to calculate the distances between a base node and all the other nodes.


use DBI;
my $database = "hwl";
my $username = "hwl_user";
my $password = "testbed";
my $hostname = "192.168.4.164";
my $db = DBI->connect("DBI:mysql:$database:$hostname", $username, $password );


my $sql_query = "select latitude,longitude,height,name from testbed_nodes where latitude!=0 and longitude!=0";
$query = $db->prepare($sql_query);
$execute = $query->execute;

while (@array = $query->fetchrow_array) {
	$lat = @array[0];
	$lon = @array[1];
	$h = @array[2];
	$name = @array[3];

	#Bezugssystem, parametrisiert durch Bezugspunkt und variablen Punkt
	my $distance = "java GeoParser 52.4293620000 13.5308670000  $lat $lon 42.0 $h";
	
	print "$name: ",`$distance`;
	#print "\t$distance\n";
}


