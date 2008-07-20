elementclass AccessPoint {
    INTERFACE $device, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL $beacon_interval |

    AddressInfo(ether_address $device:eth);
    winfo :: WirelessInfo(SSID $ssid, BSSID ether_address, CHANNEL $channel, INTERVAL $beacon_interval);
    rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);
    bs :: BeaconScanner(RT rates);

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
    -> BRNAssocResponder(DEBUG 0, WIRELESS_INFO winfo, RT rates )
    -> [0]output;

    mgt_cl[1]
    -> Discard;

    mgt_cl[2]
    -> BeaconSource(WIRELESS_INFO winfo, RT rates)
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
    -> [0]output;
}

AddressInfo(my_wlan DEVICE:eth);
wlan_out_queue :: NotifierQueue(50);

mywlan :: AddressInfo(ether_address DEVICE:eth);

tun :: KernelTun(1.0.0.1/8);

ap :: AccessPoint( INTERFACE DEVICE, SSID "brn", CHANNEL 11, BEACON_INTERVAL 100);

FromDevice(DEVICE)
  -> AthdescDecap()
  -> FilterPhyErr()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> mgm_clf :: Classifier(0/00%0f, -);				// management frames

mgm_clf[0] 							//handle mgmt frames
  -> ap
  -> beacon_rates :: SetTXRate(RATE 22,TRIES 1)		// ap beacons send at constant bitrate
  -> beacon_power :: SetTXPower( POWER 16)
  -> wlan_out_queue;

mgm_clf[1]
  -> WifiDecap()
  -> clf_bcast :: Classifier(0/ffffffffffff, -)
  -> arp_clf :: Classifier (12/0806, - )
  -> ARPResponder( 192.168.1.1/24 06:0C:42:0C:74:0D )
  -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  -> SetTXRate(RATE 22,TRIES 9)
  -> SetTXPower( POWER 16 )
  -> wlan_out_queue;

  arp_clf[1] -> Discard;

  arp :: ARPTable();

  clf_bcast[1]
    -> Classifier(12/0800)
    -> apclassifier :: Classifier(30/c0a80101,-)
    -> StoreIPEthernet(arp)
    -> EtherDecap()
    -> CheckIPHeader
    -> icp :: ICMPPingResponder
    -> ResolveEthernet( 06:0C:42:0C:74:0D, arp)
    -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
    -> SetTXRate(RATE 22,TRIES 9)
    -> SetTXPower( POWER 16 )
    -> wlan_out_queue;

    apclassifier[1]
    -> EtherDecap()
    -> Print("Up to Backend")
    -> packet_encap :: UDPIPEncap( 1.0.0.3 , 10000 , 192.168.4.3 , 12345, true )
    -> ipqueue :: NotifierQueue(50)
    -> tun;

BRN2PacketSource(1000, 2000, 1000)
-> packet_encap2 :: UDPIPEncap( 1.0.0.3 , 10000 , 192.168.4.3 , 12000, true )
-> ipqueue;

wlan_out_queue
  -> AthdescEncap()
  -> ToDevice(DEVICE);

tun
  -> StripIPHeader()
  -> Strip(8)			                                                    //Strip udp
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> data_rates :: SetTXRate(RATE 22,TRIES 9)
  -> data_power :: SetTXPower( POWER 16)
  -> wlan_out_queue;

ControlSocket("TCP", 7777);

Script(
    wait RUNTIME,
    stop
);
