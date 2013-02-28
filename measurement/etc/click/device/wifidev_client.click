#include "rawwifidev.click"
#include "wifi/adhoc_or_infrastructure_client.click"
#include "wep.click"

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

#ifdef USE_WEP
  /*
   * Damit andere Arbeitsgruppen von Arbeiten mit WEP betroffen sind, sollte im WepEncap
   * ACTIVE standardmäßig auf false stehen.
   * Für WepDecap spielt das Attribut ACTIVE keine Rolle, da das Modul selber überprüft,
   * ob es sich um ein WEP-Paket handelt. Ist dies nicht der Fall, wird das Paket
   * weitergereicht. Handelt es sich aber um ein WEP-Paket, dass aber nicht
   * entschlüsselbar ist, weil vielleicht verschiedene Schlüssel verwendet wurden
   * zwischen den Kommunikanten, dann wird das Paket einfach verworfen.
   */
  wep::WepPainted(KEY "weizenbaum", ACTIVE true, DEBUG true);

#endif

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



#ifdef USE_WEP
  -> [1]wep[1]
#endif
  -> wififrame_clf :: Classifier( 0/00%0f,  // management frames
                                  1/02%03,  //fromds
                                      - ); 


  wififrame_clf[0]
    -> client
    -> SetTXPower(63)
    -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
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
#ifdef USE_WEP
    -> wep
#endif

    //-> Print("Send 1")
    -> SetTXPower(0)
    -> SetTXRates(RATE0 2, TRIES0 7, TRIES1 0, TRIES2 0, TRIES3 0)
    -> wifioutq;
  
} 
