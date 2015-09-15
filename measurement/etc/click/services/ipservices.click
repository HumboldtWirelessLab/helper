
elementclass IPSERVICES { ETHERADDRESS $ea, DHT $dht |

dsnl::BRN2DHCPSubnetList();

dhcps::BRN2DHCPServer( ETHERADDRESS 00:0:00:00:00:00, ADDRESSPREFIX 192.168.0.0/24 , ROUTER 192.168.0.1,
                       SERVER 192.168.0.1, DNS 192.168.0.1, SERVERNAME foo, DOMAIN bla, 
                       DHCPSUBNETLIST dsnl, VLANTABLE vlt, DHTSTORAGE dhtomni/dhtstorage)


arps::BRN2Arp( ROUTERIP 192.168.0.1, ROUTERETHERADDRESS 00:0f:00:00:00:00,
               PREFIX 192.168.0.0/24, DHTSTORAGE dhtomni/dhtstorage );

bind::BRN2DNSServer(SERVERNAME ".www", DOMAIN ".bloblo.org", 
                    SERVER 192.168.0.1, DHTSTORAGE dhtomni/dhtstorage)

  service_clf::Classifier( 12/0806,                  //arp
                           12/0800 23/11 36/0043,    //dhcp
                           12/0800                   //dns
                          - );


}
