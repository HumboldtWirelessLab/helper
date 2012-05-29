#include "rawwifidev.click"
#include "wifi/adhoc_or_infrastructure_client.click"

//output:
//  0: Unicast/broadcast
//
//input::
//  0: Unicast/broadcast

elementclass WIFIDEV_CLIENT { DEVICENAME $devname,
                              DEVICE $device,
                              ETHERADDRESS $etheraddress,
                              SSID $ssid,
                              ACTIVESCAN $active |

  auth_info :: WirelessInfo(SSID $ssid, BSSID 00:00:00:00:00:00 , CHANNEL 5);
  infra_wifiencap ::  WifiEncap(0x01, WIRELESS_INFO auth_info);

  wep_encap::WepEncap(KEY "weizenbaum", KEYID 0, ACTIVE true, DEBUG true);
  wep_decap::WepDecap(KEY "weizenbaum", KEYID 0);

  client::ADHOC_OR_INFRASTRUCTURE_CLIENT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
                                         CHANNEL 5, WIFIENCAP infra_wifiencap, WIRELESS_INFO auth_info, ACTIVESCAN $active);

 
  rawdevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);
  
  wifioutq::NotifierQueue(50);

  rawdevice
  -> filter_tx :: FilterTX()
#ifndef DISABLE_WIFIDUBFILTER
  -> WifiDupeFilter()
#endif
  //-> Print("Client Raw", TIMESTAMP true)
  -> wepframe_clf :: Classifier (1/40%40, -); // 0/08%0c  steht in wepencap.cc, seltsam

  wepframe_clf[1]
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                  1/02%03,  //fromds
                                      - ); 

  wepframe_clf
	  -> wep_decap
	  -> wififrame_clf;

  wififrame_clf[0]
    -> client
    -> wifioutq
    -> rawdevice;

  wififrame_clf[1]
    //-> Print("Receive")
    -> WifiDecap()
    -> toMe::BRN2ToThisNode(NODEADDRESS $etheraddress)
    -> [0]output; 

  toMe[1]         //broadcast 
  -> [0]output; 
  
  toMe[2] -> Discard;

  wififrame_clf[2]
    -> Discard;

  input[0]
//    -> Print("Send")
    -> infra_wifiencap
    -> wep_enable::Switch(0)

    //-> Print("Send 1")
    -> wifioutq;

  wep_enable[1]
     		-> wep_encap
     		-> wifioutq;
  
} 
