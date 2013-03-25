
elementclass DHT_FALCON { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, ROUTINGPEEK $routing_peek, DEBUG $debug |

  dhtroutingtable :: FalconRoutingTable(ETHERADDRESS $etheraddress, /*USEMD5 false,*/ DEBUG $debug);

  dhtroutemaintenance :: FalconRoutingTableMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint, DEBUG 4);
  dhtsuccessormaintenance :: FalconSuccessorMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint, DEBUG 4, OPTIMIZATION 0);
  dhtleaveorganizer :: FalconLeaveOrganizer(FRT dhtroutingtable, RETRIES 3, DEBUG $debug);

  dhtnws :: FalconNetworkSizeDetermination( FRT dhtroutingtable, DEBUG 0/*$debug*/);

#ifdef USEHAWK
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB true, NODESPERLP 255, DELAY $starttime, DEBUG 0);
#else
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB false, NODESPERLP 255, DELAY $starttime, DEBUG $debug);
#endif

  dhtrouting :: DHTRoutingFalcon(FRT dhtroutingtable, LEAVEORGANIZER dhtleaveorganizer, RESPONSIBLE 1, ENABLERANGEQUERIES false, DEBUG $debug);
  dhtroutingpeek :: FalconRoutingPeek(FRT dhtroutingtable, ROUTINGPEEK $routing_peek, DEBUG $debug);

  dhtpassivemon::FalconPassiveMonitoring(FRT dhtroutingtable, DEBUG $debug);

  input[0] //-> Print("R-in",100)
    -> frc::FalconRoutingClassifier();

  frc[0] //-> Print("R-S-in",100)
    -> dhtsuccessormaintenance 
    //-> Print("R-S-out",100)
    -> [0]output;

    dhtsuccessormaintenance[1] -> [1]output;

  frc[1]// -> Print("R-FT-in",100)
    -> dhtroutemaintenance
    //-> Print("R-out",100)
    -> [0]output;

  dhtroutemaintenance[1] -> [1]output;

  frc[2]
    -> Print("DHT-Falcon-Leave in",100)
    -> dhtleaveorganizer
    -> Print("DHT-Flacon-Leave out",100)
    -> [0]output;

  frc[3]
    //-> Print("R-NWS-in",100)
    -> dhtnws
    // -> Print("R-NWS-out",100)
    -> [0]output;
    
  dhtroutingpeek -> [0]output;

  frc[4]
    //-> Print("FalconPassive in",100)
    -> dhtpassivemon
    // -> Print("FalconPassive out",100)
    -> [0]output;
     
  ||
  
 ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |

  dhtroutingtable :: FalconRoutingTable(ETHERADDRESS $etheraddress);

  dhtroutemaintenance :: FalconRoutingTableMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint, DEBUG 4);
  dhtsuccessormaintenance :: FalconSuccessorMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint, DEBUG 4, OPTIMIZATION 0);
  dhtleaveorganizer :: FalconLeaveOrganizer(FRT dhtroutingtable, RETRIES 3, DEBUG $debug);

  dhtnws :: FalconNetworkSizeDetermination( FRT dhtroutingtable, DEBUG 4/*$debug*/);
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, NODESPERLP 255, DELAY $starttime, DEBUG $debug);

  dhtrouting :: DHTRoutingFalcon(FRT dhtroutingtable, LEAVEORGANIZER dhtleaveorganizer, RESPONSIBLE 1, ENABLERANGEQUERIES false, DEBUG $debug);

  dhtpassivemon::FalconPassiveMonitoring(FRT dhtroutingtable, DEBUG $debug);

  input[0] //-> Print("R-in",100)
    -> frc::FalconRoutingClassifier();
  
  frc[0] //-> Print("R-S-in",100)
    -> dhtsuccessormaintenance 
    //-> Print("R-S-out",100)
    -> [0]output;

  dhtsuccessormaintenance[1] -> [1]output;

  frc[1]// -> Print("R-FT-in",100)
    -> dhtroutemaintenance
    //-> Print("R-out",100)
    -> [0]output;
    
  dhtroutemaintenance[1] -> [1]output;

  frc[2]
    -> Print("DHT-Falcon-Leave in",100)
    -> dhtleaveorganizer
    -> Print("DHT-Flacon-Leave out",100)
    -> [0]output;

  frc[3]
    //-> Print("R-NWS-in",100)
    -> dhtnws
    // -> Print("R-NWS-out",100)
    -> [0]output;
	
  frc[4]
    //-> Print("FalconPassive in",100)
    -> dhtpassivemon
    // -> Print("FalconPassive out",100)
    -> [0]output;

}

