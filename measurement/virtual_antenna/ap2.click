elementclass AccessPoint {
    INTERFACE $device, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL $beacon_interval |

    AddressInfo(ether_address $device:eth);
    winfo :: WirelessInfo(SSID $ssid, BSSID ether_address, CHANNEL $channel, INTERVAL $beacon_interval);
    rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);
    bs :: BeaconScanner(RT rates);

    Idle() ->
    sc :: BRN2SetChannel($device,false)
    -> Discard;
 
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
    -> bsrc :: BRN2BeaconSource(WIRELESS_INFO winfo, RT rates, SWITCHCHANNEL sc)
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

BRN2HotSpotsConnector(STARTOFFSET 1, UPDATEINTERVAL 200000,CLICKIP 192.168.4.123, CLICKPORT 7777, PACKETIP 192.168.4.123, PACKETPORT 7776 )
-> Print("Reg")
-> UDPIPEncap( 1.0.0.2 , 10002 , 192.168.4.3 , 12000, true )
-> ipqueue :: NotifierQueue(500)
-> tun;

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
    -> Print("localPing")
    -> icp :: ICMPPingResponder
    -> ResolveEthernet( 06:0C:42:0C:74:0D, arp)
    -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
    -> SetTXRate(RATE 22,TRIES 9)
    -> SetTXPower( POWER 16 )
    -> wlan_out_queue;

    apclassifier[1]
    -> EtherDecap()
    -> Print("Up to Backend")
    -> packet_encap :: UDPIPEncap( 1.0.0.3 , 10002 , 192.168.4.3 , 12100, true )
    -> ipqueue
    -> tun;


wlan_out_queue
  -> AthdescEncap()
  -> Print("E")
  -> ToDevice(DEVICE);

tun
  -> StripIPHeader()
  -> Strip(8)			                                                    //Strip udp
  -> Print("zurueck zum Client")
  -> ResolveEthernet( 06:0C:42:0C:74:0D, arp)
  -> Print("A")
  -> WifiEncap(0x02, WIRELESS_INFO ap/winfo)
  -> Print("B")
  -> SetTXRate(RATE 22,TRIES 9)
  -> Print("C")
  -> SetTXPower( POWER 16 )
  -> Print("D")
  -> wlan_out_queue;


ControlSocket("TCP", 7777);

Script(
    wait 25,
    write ap/bsrc.channel 3,
    wait RUNTIME,
    stop
);
