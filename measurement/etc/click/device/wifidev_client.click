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

  rates::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);
                     
  auth_info :: WirelessInfo(SSID $ssid, BSSID 00:00:00:00:00:00 , CHANNEL 5);
  infra_wifiencap ::  WifiEncap(0x01, WIRELESS_INFO auth_info);
         
  client::ADHOC_OR_INFRASTRUCTURE_CLIENT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
                                         CHANNEL 5, WIFIENCAP infra_wifiencap, WIRELESS_INFO auth_info, ACTIVESCAN $active);

 
  rawdevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);
  
  wifioutq::NotifierQueue(50);

  rawdevice
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                      - ); 

  wififrame_clf[0]
    -> client
    -> wifioutq
    -> rawdevice;

  wififrame_clf[1]
//    -> Print("Receive")
    -> WifiDecap()
    -> [0]output; 

  input[0]
//    -> Print("Send")
    -> infra_wifiencap
    //-> Print("Send 1")
    -> wifioutq;
  
} 
