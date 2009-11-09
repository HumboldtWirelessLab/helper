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
                            PERIOD            20000, //3000
                            TAU               30000,
                            ETX          etx_metric,
                            PROBES  "2 250 22 1000",
//                          PROBES          "2 250",
                            RT           proberates);
                            
   
  brnToMe::BRN2ToThisNode(NODEIDENTITY id);

  wifioutq::NotifierQueue(50)
  -> TODEVICE;
  
  FROMDEVICE
  //4/-> Print("FromDev")
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                      - ); 

  wififrame_clf[0]
	-> Discard;

  wififrame_clf[1]
    -> WifiDecap()
    -> nbdetect
    //4/-> Print("Data")
    -> brn_ether_clf :: Classifier( 12/8086, - )
    //5/-> Print("Data 2")

    -> lp_clf :: Classifier( 14/06, - )
    -> BRN2EtherDecap()
    -> link_stat
    //5/-> Print("Out")
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
    -> wifioutq;
 
  brn_ether_clf[1]                                      //no brn
  -> Discard;
    
  lp_clf[1]       //brn, but no lp
  //4/-> Print("Data, no LP")
  -> brnToMe;
  
  brnToMe[0] /*5/-> Print("wifi0")/5*/ -> [0]output;
  brnToMe[1] /*5/-> Print("wifi1")/5*/ -> [1]output;
  brnToMe[2] /*5/-> Print("wifi2")/5*/ -> [2]output;

  input[0] -> brnwifi;
  input[1] -> Discard;
  
} 

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

id::BRN2NodeIdentity(wireless);

rc::Brn2RouteCache(DEBUG 0, ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
lt::Brn2LinkTable(NODEIDENTITIY id, ROUTECACHE rc, STALE 500,  SIMULATE false, CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);

device_wifi::WIFIDEV(DEVNAME NODEDEVICE, DEVICE wireless, ETHERADDRESS deviceaddress, LT lt);

bcr::BrnBroadcastRouting(NODEIDENTITY id, SOURCEADDRESS deviceaddress);

device_wifi
-> Label_brnether::Null()
-> BRN2EtherDecap()
//4/-> Print("Foo",100)
-> brn_clf::Classifier(    0/04,  //BrnDSR
                           0/11,  //SimpleFlooding
                           0/10,  //SimpleFlow
                             -  );//other
                                    
brn_clf[0] 
  //4/-> Print("In-BCR-Packet")
  -> StripBRNHeader() ->  [1]bcr;

device_wifi[1]
 //4/-> Print("BRN-In") 
 -> Label_brnether;

device_wifi[2]
 //4/->Print("BRN-In")
 -> Discard;

brn_clf[2]
//4/-> Print("rx")
-> StripBRNHeader()
-> sf::BRN2SimpleFlow(SRCADDRESS deviceaddress, DSTADDRESS 00:0f:00:00:03:00,
                      RATE 1000 , SIZE 100, MODE 0, DURATION 20000,ACTIVE 0)
-> BRN2EtherEncap()
//4/-> Print("Raus damit")
-> [0]bcr;

brn_clf[3] -> Discard;

bcr[0]
//4/-> Print("juhuhuhu")
-> toMeAfterDsr::BRN2ToThisNode(NODEIDENTITY id);

flp::SimpleFlooding();
//flp::ProbabilityFlooding(LINKSTAT device_wifi/link_stat);

sfl::Flooding(FLOODINGPOLICY flp,ETHERADDRESS deviceaddress);

brn_clf[1]
//4/-> Print("SimpleFlood-Ether-IN")
-> StripBRNHeader() -> [1]sfl[0] -> Label_brnether;

bcr[1] 
      //4/-> Print("BCR[1]-src-out")
      -> BRN2EtherEncap(USEANNO true) -> [0]sfl[1] 
      -> BRN2EtherEncap(USEANNO true)
      //4/-> Print("SimpleFlood-Ether-OUT")
      -> RandomDelayQueue(MINJITTER 5, MAXJITTER 70, DIFFJITTER 35)
      -> [0]device_wifi;

toMeAfterDsr[0] 
  //4/-> Print("DSR-out: For ME")
  -> Label_brnether;
   
toMeAfterDsr[1]
  //4/-> Print("DSR-out: Broadcast")
  -> Label_brnether;
  
toMeAfterDsr[2]
 //4/-> Print("DSR-out: Foreign/Client")
  -> [1]device_wifi;

Idle() ->
en::EventNotifier(/*DEBUG 4*/)
-> Discard;

en[1]
//-> Print("event")
-> EtherEncap( 0x8680, deviceaddress, ff:ff:ff:ff:ff:ff) -> [0]bcr;

Script(
  wait RUNTIME,
  read sfl.stat,
  read en.stats
);
