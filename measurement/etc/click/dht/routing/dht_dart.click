#ifndef DHT_DART_CLICK
#define DHT_DART_CLICK

elementclass DHT_DART { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |
  dhtroutingtable :: DartRoutingTable(ETHERADDRESS $etheraddress, DEBUG 0);
  dhtroutemaintenance :: DartRoutingTableMaintenance( DRT dhtroutingtable, ACTIVESTART false,
                                                      STARTTIME  $starttime,  UPDATEINT $updateint, DEBUG $debug);
  
dhtlprh :: DartLinkProbeHandler(DRT dhtroutingtable, LINKSTAT $lt, DEBUG 0);
 #ifdef EXPAND_NEIGHBOURHOOD 
  dhtrouting :: DHTRoutingDart(DRT dhtroutingtable,EXPANDNEIGHBOURHOOD true, DEBUG $debug)
 #else
   dhtrouting :: DHTRoutingDart(DRT dhtroutingtable,EXPANDNEIGHBOURHOOD false, DEBUG 0)
#endif
  
  input[0]
#ifdef DHT_DEBUG
    -> Print("NODENAME: R-in",100)
#endif
    -> dhtroutemaintenance
#ifdef DHT_DEBUG
    -> Print("NODENAME: R-out",100)
#endif
    -> [0]output;

  dhtroutemaintenance[1]
#ifdef DHT_DEBUG
    -> Print("NODENAME: R-out",100)
#endif
    -> [1]output;

}

#endif
