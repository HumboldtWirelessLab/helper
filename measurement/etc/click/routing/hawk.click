//TODO: change describtion
// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN Hawk packets from internal nodes
// input[2] - failed transmission of a BRN GEOR packet (broken link) from ds
// input[3] - Passiv (overhear/monitor)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN GEOR packets to internal nodes (BRN GEOR protocol)

elementclass HAWK {$ID, $dhtroutingtable, $dhtstorage, $dhtrouting, $lt, $lph, $dht, $debug |
  rt::HawkRoutingtable(LPRH $lph, SUCCM $dht/dhtsuccessormaintenance, RTM $dht/dhtroutemaintenance, LINKTABLE $lt, DEBUG 4);
  hawkroutequerier::HawkRouteQuerier( NODEIDENTITY $ID, DHTSTORAGE $dhtstorage, DHTROUTING $dhtrouting, RT rt, FRT $dhtroutingtable, DEBUG 4);
  hawkfwd::HawkForwarder( NODEIDENTITY $ID, ROUTINGTABLE rt, FALCONROUTING $dhtrouting, DEBUG 4);
  routing_peek :: HawkRoutingPeek(DEBUG 0);

  input[0]
  -> hawkroutequerier[0]
  //-> Print("On the road to fwd")
  -> [1]hawkfwd[0]
  -> BRN2EtherEncap(USEANNO true)
  -> [0]output;

  input[1]
  -> routing_peek
  -> BRN2Decap()
  -> [0]hawkfwd;

  hawkfwd[1]
  -> [1]output;

  hawkroutequerier[1]
  -> Discard;

  input[2] -> Discard;
  input[3] -> Discard;
  input[4] -> Discard;
}

