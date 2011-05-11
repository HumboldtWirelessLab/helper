#include "rawwifidev.click"
#include "wifi/access_point.click"

//output:
//  0: Gateway
//  1: Broadcast
//
//input::
//  0: Client

elementclass WIFIDEV_AP { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid,
                          CHANNEL $channel, LT $lt |

  rates::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);
  
  ap::ACCESS_POINT(DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL 100, LT $lt, RATES rates);

  wifidevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);
  wifioutq::NotifierQueue(50);
  mgtoutq::NotifierQueue(50);


  prio_s::PrioSched()
  -> wifidevice; 

  mgtoutq
  -> [0]prio_s;
  
  wifioutq
  -> [1]prio_s;

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
    -> mgtoutq;

  wififrame_clf[2]
    -> FilterBSSID(ACTIVE true, DEBUG 2, WIRELESS_INFO ap/winfo)
    -> WifiDecap()
    -> bc_clf::Classifier( 0/ffffffffffff,
                           0/000102030405,
			   - );
     
  bc_clf[0]
  -> [1]output;

  bc_clf[1]
  -> [0]output;

  input[0]
  -> clientwifi::WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  -> wifioutq;  
 
} 

