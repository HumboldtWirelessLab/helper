#include "rawwifidev.click"
#include "wifi/access_point.click"

//output:
//  0: To me and BRN
//  1: Broadcast and BRN
//  2: Foreign and BRN
//  3: To me and NO BRN
//  4: BROADCAST and NO BRN
//  5: Foreign and NO BRN
//  6: Feedback BRN
//  7: Feedback Other
//
//input::
//  0: brn
//  1: client

elementclass WIFIDEV_AP { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
#ifdef VLAN_ENABLE
                          CHANNEL $channel, LT $lt, VLANTABLE $vlt |
#else
                          CHANNEL $channel, LT $lt |
#endif

  nblist::BRN2NBList();  //stores all neighbors (known (friend) and unknown (foreign))
  nbdetect::NeighborDetect(NBLIST nblist, DEVICE $device);
  
  rates::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);

#ifdef LINKSTAT_ENABLE
  proberates::AvailableRates(DEFAULT 2 22);
  etx_metric :: BRN2ETXMetric($lt);
  
  link_stat :: BRN2LinkStat(ETHTYPE          0x0a04,
                            DEVICE          $device,
                            PERIOD             3000,
                            TAU               30000,
                            ETX          etx_metric,
//                          PROBES  "2 250 22 1000",
                            PROBES  "2 250",
                            RT           proberates);
#endif

#ifdef VLAN_ENABLE
  ap::ACCESS_POINT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates, VLAN_TABLE $vlt);
#else
  ap::ACCESS_POINT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates);
#endif

  toStation::BRN2ToStations(ASSOCLIST ap/assoclist);
  toMe::BRN2ToThisNode(NODEIDENTITY id);

  wifidevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);
  wifioutq::NotifierQueue(50);

#ifdef IG_ENABLE
  prios::PrioSched()
  -> wifidevice;

  q::NotifierQueue(500)

  qc::BRN2PacketQueueControl(QUEUESIZEHANDLER q.length, QUEUERESETHANDLER q.reset, MINP 100 , MAXP 500)
  -> EtherEncap(0x0800, $etheraddress , ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> SetTimestamp()
  -> q

#ifdef PQUEUE_ENABLE
  -> [1]prios;

  input[2]
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> [0]prios;

  wifioutq
  -> [2]prios;
#else
  -> [0]prios;

  wifioutq
  -> [1]prios;
#endif

#else

#ifdef PQUEUE_ENABLE
  prios::PrioSched()
  -> wifidevice;

  input[2]
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> [0]prios;

  wifioutq
  -> [1]prios;
#else
  wifioutq
  -> wifidevice; 
#endif

#endif

  input[0] 
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> wifioutq;
  
  wifidevice[0]
  -> filter_tx :: FilterTX()
#if WIFITYPE == 805
  -> error_clf :: WifiErrorClassifier()
#else
  -> error_clf :: FilterPhyErr()
#endif
  -> wififrame_clf :: Classifier( 1/40%40,  // wep frames
                                  0/00%0f,  // management frames
                                      - );

  wififrame_clf[0]
    -> Discard;

  wififrame_clf[1]
    -> ap
    -> wifioutq;

  wififrame_clf[2]
    -> WifiDecap()
    -> nbdetect
//  -> Print("Data")
    -> toStation[2]    //no station, no broadcast
    -> toMe[0]         //it's me
    -> brn_ether_clf :: Classifier( 12/8086, - );
    
  brn_ether_clf[0]
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
#ifdef LINKSTAT_ENABLE
    -> BRN2EtherDecap()
    -> link_stat
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> power::SetTXPower(15)
    -> brnwifi;
#else
    -> Discard;
#endif

  toStation[0]
  //-> Print("For a Station")
  -> clientwifi::WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  -> wifioutq;

   toStation[1]                
  //-> Print("Broadcast")
  -> brn_ether_clf;

 
  brn_ether_clf[1]                        //For  me or broadcast and no BRN
  -> bc_clf::Classifier( 0/ffffffffffff,
                            - )
  -> [4]output;
  
  bc_clf[1]
  -> [3]output;
  
  lp_clf[1]                               //brn, but no lp
  -> brn_bc_clf::Classifier( 0/ffffffffffff,
                             - )
  -> [1]output;
  
  brn_bc_clf[1]
  -> [0]output;
                               
  toMe[1]         //broadcast 
  -> brn_ether_clf;

  toMe[2]         //Foreign
  -> foreign_brn_ether_clf :: Classifier( 12/8086, - )
  //-> Print("BRN for a foreign station")
  -> [2]output;
     
  foreign_brn_ether_clf[1]
  //-> Print("For a foreign station")
  -> [5]output;
                            
  input[1] -> fromNodetoStation::BRN2ToStations(ASSOCLIST ap/assoclist);
  
  fromNodetoStation[0]  //For Station
  -> clientwifi;
  
  fromNodetoStation[1]  //Broadcast
  -> clientwifi;
  
  fromNodetoStation[2]  //For Unknown
  -> Discard;
 
} 

