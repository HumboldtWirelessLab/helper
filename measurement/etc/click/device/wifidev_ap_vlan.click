#include "wifidev.click"
#include "wifi/access_point_vlan.click"

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

elementclass WIFIDEV_AP_VLAN { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
                               CHANNEL $channel, LT $lt, VLANTABLE $vlt |

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
//                          PROBES  "2 250 22 1000",
                            PROBES  "2 250",
                            RT           proberates);
                            
  ap::ACCESS_POINT_VLAN(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
                   CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates);
                   
  toStation::BRN2ToStations(ASSOCLIST ap/assoclist);               
  toMe::BRN2ToThisNode(NODEIDENTITY id);

  wifidevice::WIFIDEV(DEVNAME $devname, DEVICE $device);


  input[0] 
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> wifioutq::NotifierQueue(50)
  -> wifidevice
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                      - ); 

  wififrame_clf[0]
  -> ap
	-> wifioutq;

  wififrame_clf[1]
    -> WifiDecap()
    -> nbdetect
//  -> Print("Data")
    -> toStation[2]    //no station, no broadcast
    -> toMe[0]         //it's me
    -> brn_ether_clf :: Classifier( 12/8086, - );
    
  brn_ether_clf[0]
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
    -> BRN2EtherDecap()
    -> link_stat
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> brnwifi;

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
                            
  input[1] -> fromDSRtoStation::BRN2ToStations(ASSOCLIST ap/assoclist);
  
  fromDSRtoStation[0]  //For Station
  -> clientwifi;
  
  fromDSRtoStation[1]  //Broadcast
  -> clientwifi;
  
  fromDSRtoStation[2]  //For Unknown
  -> Discard;
 
} 

