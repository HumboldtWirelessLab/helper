// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN DSR packets from internal nodes
// input[2] - failed transmission of a BRN DSR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN DSR packets to internal nodes (BRN DSR protocol)

elementclass DSR {$ID, $LT, $RC |

//  brn_encap :: BRN2Encap;
  dsr_decap :: BRN2DSRDecap(NODEIDENTITY $ID, LINKTABLE $LT);
  dsr_encap :: BRN2DSREncap(NODEIDENTITY $ID, LINKTABLE $LT);

  ridc::BrnRouteIdCache();
    
  querier :: BRN2RouteQuerier(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap/*, BRNENCAP brn_encap*/, DSRDECAP dsr_decap, DEBUG 0);
//  querier :: BRN2RouteQuerier(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, BRNENCAP brn_encap, DSRDECAP dsr_decap, DEBUG 0);

  req_forwarder :: BRN2RequestForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, DSRENCAP dsr_encap,/* BRNENCAP brn_encap,*/ ROUTEQUERIER querier, MINMETRIC 15000, DEBUG 0);
//  req_forwarder :: BRN2RequestForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, DSRENCAP dsr_encap, BRNENCAP brn_encap, ROUTEQUERIER querier, MINMETRIC 15000, DEBUG 0);
  rep_forwarder :: BRN2ReplyForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, ROUTEQUERIER querier, DSRENCAP dsr_encap);
  src_forwarder :: BRN2SrcForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, DSRIDCACHE ridc);
  err_forwarder :: BRN2ErrorForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, ROUTEQUERIER querier/*, BRNENCAP brn_encap*/);
//  err_forwarder :: BRN2ErrorForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, ROUTEQUERIER querier, BRNENCAP brn_encap);

  input[0]
//  -> Print("RouteQuery")
  -> querier[0]
//  -> Print("DSR: querie")
  -> [1]output;                                             // rreq packets (broadcast)
  
  querier[1] 
//  -> Print("DSR: src_forwarder")
  -> [0]src_forwarder;                                      // src routed packets (unicast)

  src_forwarder[0]
//  -> Print("Forward")
  -> [1]output;

  src_forwarder[1]
//  -> Print("Final dest")
  -> [0]output;

  src_forwarder[2]
//  -> Print("Error")
  -> tee_to_err_fwd :: Tee()
  -> Discard;                                                  //is for BRNiapp

  tee_to_err_fwd[1]
  -> [0]err_forwarder;

  // ------------------
  // internal packets
  // ------------------
  input[1]
  -> dsrclf :: Classifier( 6/01, //DSR_RREQ
                           6/02, //DSR_RREP
                           6/03, //DSR_RERR
                           6/04, //DSR_SRC
                         );

  dsrclf[0]
  -> Print("Req_fwd_in")
  -> req_forwarder[0]
  -> Print("Req_fwd_out")
  -> [1]output;

  req_forwarder[1]
  -> Print("Target! now send reply")
  -> [0]rep_forwarder
  -> [1]output;

  dsrclf[1] 
  -> Print("Route Reply")
  -> [1]rep_forwarder;

  dsrclf[2]
  -> [1]err_forwarder
  -> [1]output;

  dsrclf[3]
 // -> Print("SRCFWD")
  -> [1]src_forwarder;

  // ------------------
  // undeliverable packets
  // ------------------
  input[2]
  -> [0]err_forwarder;
}

//output:
//  0: To me and BRN
//  1: Broadcast and BRN
//  2: Foreign and BRN
//  3: To me and NO BRN
//  4: Foreign and NO BRN
//  5: BROADCAST and NO BRN
//  6: Feedback BRN
//  7: Feedback Other
//
//input::
//  0: brn
//  1: client

elementclass WIFIDEV { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, LT $lt |

  nblist::BRN2NBList();  //stores all neighbors (known (friend) and unknown (foreign))
  nbdetect::NeighborDetect(NBLIST nblist, DEVICE $device);
  rates::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);
  proberates::AvailableRates(DEFAULT 2 22);
  etx_metric :: BRN2ETXMetric($lt);
  
  link_stat :: BRN2LinkStat(ETHTYPE          0x0a04,
                            DEVICE          $device,
                            PERIOD             3000,
                            TAU               30000,
                            ETX          etx_metric,
                          PROBES  "2 250 22 1000",
//                            PROBES  "2 250",
                            RT           proberates);
                            
   
  brnToMe::BRN2ToThisNode(NODEIDENTITY id);

  wifioutq::NotifierQueue(50)
  -> TODEVICE;
  //-> AddEtherNsclick()
  //-> Print("To Device")
  //-> toDevice::ToSimDevice($devname);
  
  //FromSimDevice($devname, SNAPLEN 1500)
  //-> Strip(14)                              //-> ATH2Decap(ATHDECAP true)
  //  -> Print("FromDev")
  FROMDEVICE
  -> FilterPhyErr()
  -> filter :: FilterTX()
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                      - ); 

  wififrame_clf[0]
	-> Discard;

  wififrame_clf[1]
    -> WifiDecap()
    -> nbdetect
//    -> Print("Data")
    -> brn_ether_clf :: Classifier( 12/8086, - )
    -> lp_clf :: Classifier( 14/06, - )
    -> BRN2EtherDecap()
    -> link_stat
//  -> Print("Out")
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
    -> wifioutq;
 
  brn_ether_clf[1]                                      //no brn
  -> Discard;
    
  lp_clf[1]       //brn, but no lp
  //-> Print("Data, no LP")
  -> brnToMe;
  
  brnToMe[0] -> /*Print("wifi0") ->*/ [0]output;
  brnToMe[1] -> /*Print("wifi1") ->*/ [1]output;
  brnToMe[2] -> /*Print("wifi2") ->*/ [2]output;

  input[0] -> brnwifi;
  input[1] -> Discard;
  
} 

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

id::BRN2NodeIdentity(wireless);

rc::Brn2RouteCache(DEBUG 0, ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
lt::Brn2LinkTable(NODEIDENTITIY id, ROUTECACHE rc, STALE 500,  SIMULATE false, CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);

device_wifi::WIFIDEV(DEVNAME NODEDEVICE, DEVICE wireless, ETHERADDRESS deviceaddress, LT lt);

dsr::DSR(id,lt,rc);

device_wifi
-> Label_brnether::Null()
-> BRN2EtherDecap()
//-> Print("Foo",100)
-> brn_clf::Classifier(    0/03,  //BrnDSR
                           0/10,  //Simpleflow
                             -  );//other
                                    
brn_clf[0] -> /*Print("DSR-Packet") -> */ [1]dsr;

device_wifi[1] -> /*Print("BRN-In") -> */ BRN2EtherDecap() -> brn_clf;
device_wifi[2] -> Discard;

Idle -> [2]dsr;

brn_clf[1]
//-> Print("rx")
-> StripBRNHeader()
-> sf::BRN2SimpleFlow(SRCADDRESS deviceaddress, DSTADDRESS 00:0f:00:00:01:00,
                      RATE 1000 , SIZE 100, MODE 0, DURATION 20000, ACTIVE 0)
-> BRN2EtherEncap()
-> [0]dsr;

brn_clf[2] -> Discard;

dsr[0] -> toMeAfterDsr::BRN2ToThisNode(NODEIDENTITY id);
dsr[1] /*-> Print("DSR[1]-out")*/ -> BRN2EtherEncap() -> SetEtherAddr(SRC deviceaddress) /*-> Print("DSR-Ether-OUT")*/ -> [0]device_wifi;

toMeAfterDsr[0] -> /*Print("DSR-out: For ME",100) ->*/ Label_brnether; 
toMeAfterDsr[1] -> /*Print("DSR-out: Broadcast") ->*/ Discard;
toMeAfterDsr[2] -> /*Print("DSR-out: Foreign/Client") ->*/ [1]device_wifi;

Script(
  wait RUNTIME,
  read lt.links,
  stop
);
