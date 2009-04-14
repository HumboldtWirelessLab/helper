elementclass AccessPoint {
    INTERFACE $device, WDEV $wdev,SSID $ssid, CHANNEL $channel, BEACON_INTERVAL $beacon_interval, LT $lt |

    BRNAddressInfo(ether_address $device:eth);
    winfo :: WirelessInfo(SSID $ssid, BSSID ether_address, CHANNEL $channel, INTERVAL $beacon_interval);
    rates :: AvailableRates(DEFAULT 2 4 11 12 18 22 108);
    bs :: BeaconScanner(RT rates);
    assoclist :: BRN2AssocList(LINKTABLE $lt);

    input[0]
    -> mgt_cl :: Classifier(  0/00%f0, //assoc req
                                        0/10%f0, //assoc resp
                                        0/40%f0, //probe req
                                        0/50%f0, //probe resp
                                        0/80%f0, //beacon
                                        0/a0%f0, //disassoc
                                        0/b0%f0, //disassoc
          );

    mgt_cl[0]
    -> Print("Assoc Request")
    -> BRN2AssocResponder(DEBUG 0, DEVICE $wdev, ASSOCLIST assoclist, WIRELESS_INFO winfo, RT rates )
    -> Print("assoc")
    -> [0]output;

    mgt_cl[1]
    -> Discard;

    mgt_cl[2]
    -> Print("Probe request")
    -> bsrc :: BRN2BeaconSource(WIRELESS_INFO winfo, RT rates)
    -> Print("Beacon")
    -> [0]output;

    mgt_cl[3]
    -> Discard;

    mgt_cl[4]
    -> bs                                                                             //BeaconScanner
    -> Discard; 

    mgt_cl[5]
    -> Discard;

    mgt_cl[6]
    -> OpenAuthResponder(WIRELESS_INFO winfo)
    -> Print("Auth")
    -> [0]output;
}

BRNAddressInfo(my_wlan NODEDEVICE:eth);
wlan_out_queue :: NotifierQueue(50);

BRNAddressInfo(ether_address NODEDEVICE:eth);

wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS my_wlan, DEVICETYPE "WIRELESS");
id::BRN2NodeIdentity(wireless);

rc::BrnRouteCache(DEBUG 0, ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
lt::Brn2LinkTable(NODEIDENTITIY id, ROUTECACHE rc, STALE 500,  SIMULATE false,
                  CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);


ap :: AccessPoint( INTERFACE NODEDEVICE, WDEV wireless, SSID "brn", CHANNEL 11, BEACON_INTERVAL 100, LT lt);

FROMDEVICE
  -> FilterPhyErr()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> Print("in")
  -> mgm_clf :: Classifier(0/00%0f, -);				// management frames

mgm_clf[0] 							//handle mgmt frames
  -> ap
  -> beacon_rates :: SetTXRate(RATE 22,TRIES 3)		// ap beacons send at constant bitrate
  -> beacon_power :: SetTXPower( POWER 16)
  -> wlan_out_queue;

mgm_clf[1]
-> Discard;
 Idle()
  -> WifiDecap()
  -> clf_bcast :: Classifier(0/ffffffffffff, -)
  -> arp_clf :: Classifier (12/0806, - )
  -> ARPResponder( 192.168.1.1/24 06:0c:42:0c:74:0e )
  -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  -> SetTXRate(RATE 108,TRIES 9)
  -> SetTXPower( POWER 16 )
//  -> wlan_out_queue;
-> Discard;
  
  arp_clf[1] -> Discard;

  arp :: ARPTable();

  clf_bcast[1]
  -> Discard;
  Idle
    -> Classifier(12/0800)
    -> StoreIPEthernet(arp)
    -> EtherDecap()
    -> CheckIPHeader
    -> Print("localPing")
    -> icp :: ICMPPingResponder
    -> ResolveEthernet( 06:0c:42:0c:74:0e, arp)
    -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
    -> SetTXRate(RATE 108,TRIES 9)
    -> SetTXPower( POWER 16 )
    -> Discard;
//    -> wlan_out_queue;

wlan_out_queue
  -> TODEVICE;

Script(
//    wait 25,
//    write ap/bsrc.channel 3,
    wait RUNTIME,
    stop
);
