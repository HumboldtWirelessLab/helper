#!/usr/bin/perl -w
use DBI;

# Connect To Database
$database = "ndoutils";
$username = "testbed";
$password = "testbed";
$hostname = "192.168.4.188";
$db = DBI->connect("DBI:mysql:$database:$hostname", $username, $password );

$qstr = "select nagios_hosts.alias from nagios_hostgroups,nagios_hostgroup_members,nagios_hosts,nagios_hoststatus,nagios_services,nagios_servicestatus where nagios_hostgroups.hostgroup_id=nagios_hostgroup_members.hostgroup_id and nagios_hostgroups.alias like 'brn-testbed' and nagios_hostgroup_members.host_object_id=nagios_hosts.host_object_id and nagios_hosts.host_object_id=nagios_hoststatus.host_object_id and nagios_hoststatus.current_state=0 and nagios_services.service_object_id = nagios_servicestatus.service_object_id and nagios_services.host_object_id = nagios_hosts.host_object_id and nagios_servicestatus.current_state = 0 and nagios_services.display_name like '";
$qstr .= "$ARGV[0]";
$qstr .= "';";
#$qstr = "select * from nagios_hosts;";

$query = $db->prepare("$qstr");
$query->execute;

while (@array = $query->fetchrow_array) {
   ($name) = @array;
   print $name;
   print "\n";
}

exit(0);

