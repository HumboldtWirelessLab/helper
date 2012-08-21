#include "rawwifidev.click"
#include "wifi/access_point.click"
#include "wep_painted.click"

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
//  2: high priority stuff

/*
 * Dieses Device besitzt aus historischen Gründen mehrere Funktionen. Es behandelt Pakete
 * aus den unterschiedlichsten Netzwerkschichten, um z. B. das Leistungsverhalten zu verbessern
 * oder besondere Informationen (z. B. Statistik, Analyse) zu erhalten. Daher sind die
 * Herkunftsort von Paketen, die über das Device transportiert werden sollen, aus 5
 * verschiedenen Quellen:
 * 1. Linkstat: Linkprobing-Pakete
 * 2. Interferenzgraph: Pakete werden erzeugt, um die Stärke von Interferenz auszumessen
 * 		// todo: mittels 3. realisieren
 * 3. UpperLayer-Wififrames: Hier kommen wififrames von oben
 * 4. Mesh: Pakete, die für das Maschennetzwerk sind.
 * 5. Client: Pakete für Clienten.
 */



elementclass WIFIDEV_AP { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
#ifdef VLAN_ENABLE
                          CHANNEL $channel, LT $lt, VLANTABLE $vlt |
#else
                          CHANNEL $channel, LT $lt |
#endif

//#warning Fix NBList in wifidev_ap
//  nblist::BRN2NBList(NODEID );  //stores all neighbors (known (friend) and unknown (foreign))
//  nbdetect::NeighborDetect(NBLIST nblist);

  rates::BrnAvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);

#ifdef LINKSTAT_ENABLE
  proberates::BrnAvailableRates(DEFAULT 2 22);
  etx_metric :: BRN2ETXMetric($lt);
  
  link_stat :: BRN2LinkStat(ETHTYPE          0x0a04,
                            DEVICE          $device,
                            PERIOD             3000,
                            TAU               30000,
                            METRIC     "etx_metric",
//                          PROBES  "2 250 22 1000",
                            PROBES  "2 250",
                            RT           proberates);
#endif

#ifdef VLAN_ENABLE
  ap::ACCESS_POINT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates, VLANTABLE $vlt);
#else
  ap::ACCESS_POINT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates);
#endif

  toStation::BRN2ToStations(ASSOCLIST ap/assoclist);
  toAP::BRN2ToThisNode(NODEIDENTITY id);
  toMe::BRN2ToThisNode(NODEIDENTITY id);

  wifidevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);
  wifioutq::NotifierQueue(50);

#ifdef USE_WEP
  wep::WepPainted(KEY "weizenbaum", ACTIVE true, DEBUG true);
#endif

#ifdef IG_ENABLE
  prios::PrioSched()
  -> wifidevice;

  qc_suppressor::Suppressor();
  q::NotifierQueue(500);

  qc::BRN2PacketQueueControl(QUEUESIZEHANDLER q.length, QUEUERESETHANDLER q.reset, MINP 100 , MAXP 500, SUPPRESSORHANDLER qc_suppressor.active0,DISABLE_QUEUE_RESET false, TXFEEDBACK_REUSE false, UNICAST_RETRIES 0)
  -> EtherEncap(0x0800, $etheraddress , ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> SetTimestamp()
  -> q
  -> qc_suppressor
  // -> cnt::Counter()
  
#ifdef PQUEUE_ENABLE
  -> [1]prios;

  input[2]
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
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
#ifdef USE_WEP
  -> wep
#endif
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
  -> SetTXPower(0)
  -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
  -> wifioutq;
  
  wifidevice[0]
  -> filter_tx :: FilterTX()
#if WIFITYPE == 805
  -> error_clf :: WifiErrorClassifier()
#else
  -> error_clf :: FilterPhyErr()
#endif
#ifndef DISABLE_WIFIDUBFILTER
  -> WifiDupeFilter()
#endif
#ifdef USE_WEP
  -> [1]wep[1]
#endif
   -> wififrame_clf :: Classifier(0/00%0f,  // management frames
                                   1/01%03,  //tods
                                       - );

  wififrame_clf[0]
    -> fb::FilterBSSID(ACTIVE true, DEBUG 1, WIRELESS_INFO ap/winfo)
    -> ap
    -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
    -> wifioutq;

  fb[1]
    -> Classifier( 16/ffffffffffff )
    -> ap;

  wififrame_clf[1]
    //-> Print("Filter",TIMESTAMP true)
    -> fbssid::FilterBSSID(ACTIVE true, DEBUG 1, WIRELESS_INFO ap/winfo)
    -> WifiDecap()
//  -> nbdetect
    //-> Print("Data",TIMESTAMP true)
    -> toStation[2]    //no station, no broadcast
    -> toAP[0]         //it's me
    -> brn_ap_clf :: Classifier( 12/8086, - )
    -> [0]output;


  toStation[0]
    //-> Print("For a Station",TIMESTAMP true)
    -> clientwifi::WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  //-> Print("Und wieder raus",TIMESTAMP true)
#ifdef USE_WEP
    -> wep
#endif
    -> SetTXPower(0)
    -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
    -> wifioutq;

  toStation[1]                
    //-> Print("Broadcast",TIMESTAMP true)
    -> brn_ap_clf;
    
    toAP[1] 
    //-> Print("a")
    -> brn_ap_clf;
    
    toAP[2]
    //-> Print("b")
    -> [2]output;
    
    brn_ap_clf[1] -> [3]output;
        
  wififrame_clf[2]
    -> WifiDecap()
    -> toMe[1]          //it's broadcast
    -> brn_bc_clf :: Classifier( 12/8086, - );
  
  brn_bc_clf[0]
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
#ifdef LINKSTAT_ENABLE
    -> BRN2EtherDecap()
    -> link_stat
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> power::SetTXPower(0) //15
    -> brnwifi;
#else
    -> Discard;
#endif

  lp_clf[1]
  -> [1]output;
  
  brn_bc_clf[1]
  -> [4]output;

  toMe[0]         //it's me
  -> brn_ether_clf :: Classifier( 12/8086, - )
  -> [0]output;
  
  brn_ether_clf[1]                        //For  me or broadcast and no BRN
  -> Discard;
  
  
  toMe[2]         //Foreign
  -> foreign_brn_ether_clf :: Classifier( 12/8086, - )
  //-> Print("BRN for a foreign station")
  -> Discard;//[2]output;
     
  foreign_brn_ether_clf[1]
  //-> Print("For a foreign station")
  -> Discard; //-> [5]output;
    
                          
  input[1] -> fromNodetoStation::BRN2ToStations(ASSOCLIST ap/assoclist);
  
  fromNodetoStation[0]  //For Station
  -> clientwifi;
  
  fromNodetoStation[1]  //Broadcast
  -> clientwifi;
  
  fromNodetoStation[2]  //For Unknown
  -> Discard;

  Idle -> [1]ap[1] -> Discard;
  Idle -> [2]ap[2] -> Discard;
 
  Idle -> [5]output;
} 

