
elementclass DHT_FALCON { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, ROUTINGPEEK $routing_peek, DEBUG $debug |

  dhtroutingtable :: FalconRoutingTable(ETHERADDRESS $etheraddress, /*USEMD5 false,*/ DEBUG $debug);



#ifndef PM_ROUNDS
#define PM_ROUNDS 0
#endif

#ifdef SUCCFORWARD
#define FALCON_SUCC_OPT 1
#else

#ifdef SUCCFORWARD_WITH_HINT
#define FALCON_SUCC_OPT 3

#else

#ifdef SUCC_HINT
#define FALCON_SUCC_OPT 2

#else
#define FALCON_SUCC_OPT 0
#endif
#endif
#endif

  dhtroutemaintenance :: FalconRoutingTableMaintenance( FRT dhtroutingtable, STARTTIME $starttime, PMROUNDS PM_ROUNDS, OPTIMIZATION FALCON_SUCC_OPT, UPDATEINT $updateint, DEBUG 0);

  dhtsuccessormaintenance :: FalconSuccessorMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint, DEBUG 0, OPTIMIZATION FALCON_SUCC_OPT);


  dhtleaveorganizer :: FalconLeaveOrganizer(FRT dhtroutingtable, RETRIES 3, DEBUG $debug);

  dhtnws :: FalconNetworkSizeDetermination( FRT dhtroutingtable, DEBUG 0 /*$debug*/);

#ifdef USEHAWK
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB true, NODESPERLP 255 , DELAY $starttime, DEBUG $debug);
#else
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB false, NODESPERLP 255 , DELAY $starttime, DEBUG $debug);
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

  dhtroutingtable :: FalconRoutingTable(ETHERADDRESS $etheraddress, DEBUG 0);

#ifndef PM_ROUNDS
#define PM_ROUNDS 0
#endif

#ifdef SUCCFORWARD
#define FALCON_SUCC_OPT 1
#else

#ifdef SUCCFORWARD_WITH_HINT
#define FALCON_SUCC_OPT 3

#else

#ifdef SUCC_HINT
#define FALCON_SUCC_OPT 2

#else
#define FALCON_SUCC_OPT 0
#endif
#endif
#endif

#ifndef LPS
#define LPS 255
#endif

#ifndef SUCCPING
#define SUCCPING 3
#endif
  dhtroutemaintenance :: FalconRoutingTableMaintenance( FRT dhtroutingtable, STARTTIME $starttime, PMROUNDS PM_ROUNDS, OPTIMIZATION FALCON_SUCC_OPT , UPDATEINT $updateint, DEBUG 2);

  dhtsuccessormaintenance :: FalconSuccessorMaintenance( FRT dhtroutingtable, STARTTIME $starttime, UPDATEINT $updateint,MINSUCCESSORPING SUCCPING, OPTIMIZATION FALCON_SUCC_OPT, DEBUG 2);

  dhtleaveorganizer :: FalconLeaveOrganizer(FRT dhtroutingtable, RETRIES 3, DEBUG $debug);

  dhtnws :: FalconNetworkSizeDetermination( FRT dhtroutingtable, DEBUG $debug);

#ifdef USEHAWK
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB true, NODESPERLP LPS, DELAY $starttime, DEBUG $debug);
#else
  dhtlprh :: FalconLinkProbeHandler(FRT dhtroutingtable, LINKSTAT $lt, REGISTERHANDLER true, ONLYFINGERTAB false, NODESPERLP LPS, DELAY $starttime, DEBUG $debug);
#endif

  dhtrouting :: DHTRoutingFalcon(FRT dhtroutingtable, LEAVEORGANIZER dhtleaveorganizer, RESPONSIBLE 1, ENABLERANGEQUERIES false, DEBUG 2);

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

  dhtroutemaintenance[1]
    -> [1]output;

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

