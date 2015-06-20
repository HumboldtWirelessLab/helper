#ifndef DART_CLICK
#define DART_CLICK

// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN GEOR packets from internal nodes
// input[2] - failed transmission of a BRN GEOR packet (broken link) from ds
// input[3] - passive (overhear)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN GEOR packets to internal nodes (BRN GEOR protocol)
// [2]output - Feedback packets for upper layer

elementclass DART {$ID, $dhtroutingtable, $dhtstorage, $dhtrouting, $lt |

  DartIDStore( NODEIDENTITY  $ID, DHTSTORAGE $dhtstorage, DRT $dhtroutingtable, LT $lt, DEBUG 0);

  dartidcache::DartIDCache();
  dartroutequerier::DartRouteQuerier( NODEIDENTITY $ID, DHTSTORAGE $dhtstorage, DARTIDCACHE dartidcache, DRT $dhtroutingtable, DEBUG 0);
#ifdef OPT_ROUTING
  dartfwd::DartForwarder( NODEIDENTITY $ID, DARTIDCACHE dartidcache,OPT 1,  DARTROUTING $dhtrouting, DRT $dhtroutingtable, DEBUG 0);
#else
  dartfwd::DartForwarder( NODEIDENTITY $ID, DARTIDCACHE dartidcache,OPT 0,  DARTROUTING $dhtrouting, DRT $dhtroutingtable, DEBUG 0);
#endif
  routing_peek :: DartRoutingPeek(DEBUG 0);

  input[0]
  -> dartroutequerier[0]
  //-> Print("On the road to fwd")
  -> [1]dartfwd[0]
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

  input[1]
  -> routing_peek
  -> BRN2Decap()
  -> [0]dartfwd;

  dartfwd[1]
  -> [0]output;

  dartroutequerier[1]
  -> Discard;

  input[2]
  -> Discard;

  input[3]
  -> Discard;

  input[4]
  -> Discard;

#ifdef ROUTING_TXFEEDBACK
  Idle -> [2]output;
#endif

}

#endif
