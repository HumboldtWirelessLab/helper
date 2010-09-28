// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN GEOR packets from internal nodes
// input[2] - failed transmission of a BRN GEOR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN GEOR packets to internal nodes (BRN GEOR protocol)

elementclass DART {$ID, $dhtroutingtable, $dhtstorage, $dhtrouting |
  DartIDStore( NODEIDENTITY  $ID, DHTSTORAGE $dhtstorage, DRT $dhtroutingtable, DEBUG 2);
  
  dartidcache::DartIDCache();  
  dartroutequerier::DartRouteQuerier( NODEIDENTITY $ID, DHTSTORAGE $dhtstorage, DARTIDCACHE dartidcache, DRT $dhtroutingtable, DEBUG 2);
  dartfwd::DartForwarder( NODEIDENTITY $ID, DARTIDCACHE dartidcache,  DARTROUTING $dhtrouting, DRT $dhtroutingtable, DEBUG 2);
  
  input[0]
  -> dartroutequerier[0]
  //-> Print("On the road to fwd")
  -> [0]dartfwd[0]
  -> [0]output;
  
  input[1]
  -> BRN2Decap()
  -> [0]dartfwd;
  
  dartfwd[1]
  -> [1]output;
  
  dartroutequerier[1]
  -> Discard;
  
  input[2]
  -> Discard;
}

