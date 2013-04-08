#ifndef DHT_DART_CLICK
#define DHT_DART_CLICK

elementclass DHT_DART { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |
  dhtroutingtable :: DartRoutingTable(ETHERADDRESS $etheraddress);
  dhtroutemaintenance :: DartRoutingTableMaintenance( DRT dhtroutingtable, ACTIVESTART false,
                                                      STARTTIME  $starttime,  UPDATEINT $updateint, DEBUG $debug);
  dhtlprh :: DartLinkProbeHandler(DRT dhtroutingtable, LINKSTAT $lt, DEBUG 4);

  dhtrouting :: DHTRoutingDart(DRT dhtroutingtable, DEBUG $debug)

  input[0]
    -> Print("NODENAME: R-in",100)
    -> dhtroutemaintenance
    -> Print("NODENAME: R-out",100)
    -> [0]output;

  dhtroutemaintenance[1]
    -> Print("NODENAME: R-out",100)
    -> [1]output;

}

#endif
