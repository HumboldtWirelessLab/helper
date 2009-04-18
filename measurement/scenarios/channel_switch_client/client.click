BRNAddressInfo(deviceaddress NODEDEVICE:eth);
BRNAddressInfo(my_wlan NODEDEVICE:eth);

wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

id::BRN2NodeIdentity(wireless);

wlan_out_queue :: NotifierQueue(50);

elementclass AdHocOrInfraStructureClient {
    ETH $eth, SSID $ssid, CHANNEL $channel , WIFIENCAP $clientwifiencap, 
    WIRELESS_INFO $auth_info |

    auth_rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);

    probe_req :: ProbeRequester(WIRELESS_INFO $auth_info, ETH $eth, RT auth_rates);
    auth_req :: OpenAuthRequester(ETH $eth, WIRELESS_INFO $auth_info);
    assoc_req :: BRNAssocRequester(ETH $eth, WIRELESS_INFO $auth_info, RT auth_rates, DEBUG 0);

    bs :: BRN2BeaconScanner(RT auth_rates);
 
    isc :: BRN2InfrastructureClient(WIRELESS_INFO $auth_info, RT auth_rates, 
      BEACONSCANNER bs, PROBE_REQUESTER probe_req, AUTH_REQUESTER auth_req, 
      ASSOC_REQUESTER assoc_req, WIFIENCAP $clientwifiencap);

    input[0]
    -> mgt_cl :: Classifier(0/00%f0, //Association Request
                            0/10%f0, //Association Response
                            0/20%f0, //Reassociation Request            
                            0/30%f0, //Reassociation Response
		        0/40%f0, //Probe Request 
                            0/50%f0, //Probe Response
                            0/80%f0, //Beacon
			    0/90%f0, //ATIM (Power Save)
                            0/a0%f0, //Deassociation
                            0/b0%f0, //Authentification
			    0/c0%f0  //De-Authentification
          );


    mgt_cl[0]  //Association Request
    -> Discard;    

    mgt_cl[1]  //Association Response
    -> Print("Bekomme Association Response")
    -> assoc_req
    -> Print("Sende Association Request")
    -> [0]output;

    mgt_cl[2]  //Reassociation Request
    -> Discard;

    mgt_cl[3]  //Reassociation Response
    -> Print("Bekomme Reassociation Response")
    -> assoc_req;

    mgt_cl[4]  //Probe Request
    -> Discard;

    mgt_cl[5]  //Probe Response
    -> PrintWifi("Bekomme Probe Response in den Beaconscanner")
    -> bs
    -> Discard;
    
    probe_req
    -> Print("Send Probe",64)
    -> [0]output;

    mgt_cl[6]  //Beacon
    -> PrintWifi("Bekomme Beacon: ")
    -> bs;

    mgt_cl[7]  //ATIM (Power Save)
    -> Discard;

    mgt_cl[8]  //Deassociation
//  -> Print("Bekomme deassoc",64)
    -> assoc_req;

    mgt_cl[9]  //Authentification
    -> Print("bekomme AUTH")
    -> auth_req    
    -> Print("Send AUTH ",128)
    -> [0]output;

    mgt_cl[10]  //De-Authentification
    -> Discard;

}

auth_info :: WirelessInfo(SSID brn, BSSID 00:00:00:00:00:00 , CHANNEL 11);

Idle()
-> infra_wifiencap ::  WifiEncap(0x01, WIRELESS_INFO auth_info)
-> Discard;

infra_client :: AdHocOrInfraStructureClient( ETH my_wlan, SSID brn, CHANNEL 11, WIFIENCAP infra_wifiencap, WIRELESS_INFO auth_info );

rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);

// ----------------------------------------------------------------------------
// Handling ath0-device
// ----------------------------------------------------------------------------
FROMDEVICE
  -> FilterPhyErr()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> mgm_clf :: Classifier(0/00%0f, -); // management frames

mgm_clf[0]          //handle mgmt frames
  -> infra_client
  -> SetTXRate(2) // ap beacons send at constant bitrate
  -> wlan_out_queue;

mgm_clf[1]           //handle other frames (data)
  -> WifiDecap()
  -> clf_bcast :: Classifier(0/ffffffffffff, -); // broadcast & unicast packets

clf_bcast[0]
  -> Discard();

//
// handle Unicast
//
clf_bcast[1]                                      //Unicast
//  -> Print("Client: Unicast (in): ",256)           //simple packets (no brn) (only IP)
//  -> Classifier(12/0800)                    // ip packet (don't handle IP-Packets in simulation -> Discard
// -> EtherDecap()
//  -> CheckIPHeader()
//  -> IPPrint("Client")
  -> Discard();

//BRN intern and other Clients

  wlan_out_queue
  -> TODEVICE;
  
filter[1]
  -> Discard;                                              //take a closer look at tx-annotated packets

//mysrc :: RatedSource("ABCDEFGHIJKLMNOPQRSTUWVXYZ", 5, 10 , false)
//-> Print("--------------- Start: Sending new Packet")
//-> UDPIPEncap( 192.168.0.2 , 1000 , 192.168.0.1 , 80 )
//-> tst::SetTimestamp()
//-> CheckIPHeader()
//-> IPPrint("Client")
//-> EtherEncap(0x0800, my_wlan, ff:ff:ff:ff:ff:ff)
//-> Print("Client: Send Packet to AP")
//-> infra_wifiencap
//-> wlan_out_queue;

 
Script(
  wait 20,
  read infra_client/isc.wireless_info,
  read infra_client/isc.assoc,
  wait 5,
  write mysrc.active true,
);
