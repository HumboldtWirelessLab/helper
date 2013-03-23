
elementclass DHT_DART { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |
  dhtroutingtable :: DartRoutingTable(ETHERADDRESS $etheraddress);
  dhtroutemaintenance :: DartRoutingTableMaintenance( DRT dhtroutingtable, ACTIVESTART false,
                                                      STARTTIME  $starttime,  UPDATEINT $updateint, DEBUG $debug);
  dhtlprh :: DartLinkProbeHandler(DRT dhtroutingtable, LINKSTAT $lt, DEBUG 4);
  
  dhtrouting :: DHTRoutingDart(DRT dhtroutingtable, DEBUG $debug)
  
  input[0]
  //-> Print("R-in",100)
    -> dhtroutemaintenance
  //-> Print("R-out",100)
    -> [0]output;

  dhtroutemaintenance[1]
    -> [1]output;

}

