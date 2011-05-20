#!/bin/bin/perl
# autor: chris ricardo
# email: kuehne@informatik.hu-berlin.de

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
	#my $distance = `java GeoParser 13.530465 52.429475  $lon $lat 38.0 $h`;
	my $distance = `java GeoParser  13.530887  52.429347 $lat $lon `;

	print "$name: $distance";
	print "(java GeoParser 13.530465  52.429475  $lat $lon 38.0 $h) \n";
}


