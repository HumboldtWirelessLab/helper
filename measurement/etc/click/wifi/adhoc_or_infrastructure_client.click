//input::
//  0: managment frames
//
//output:
//  0: managment frames
//  1: unknown frames

elementclass ADHOC_OR_INFRASTRUCTURE_CLIENT {
    DEVICE $device,
    ETHERADDRESS $eth,
    SSID $ssid,
    CHANNEL $channel,
    WIFIENCAP $clientwifiencap, 
    WIRELESS_INFO $auth_info,
    ACTIVESCAN $active |

    auth_rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);

    probe_req :: ProbeRequester(WIRELESS_INFO $auth_info, ETH $eth, RT auth_rates);
    auth_req :: OpenAuthRequester(ETH $eth, WIRELESS_INFO $auth_info);
    assoc_req :: BRN2AssocRequester(ETH $eth, WIRELESS_INFO $auth_info, RT auth_rates, DEBUG 0);

    bs :: BRN2BeaconScanner(RT auth_rates, DEBUG 2);
 
    isc :: BRN2InfrastructureClient(WIRELESS_INFO $auth_info, RT auth_rates, 
                                    BEACONSCANNER bs, PROBE_REQUESTER probe_req, AUTH_REQUESTER auth_req, 
                                    ASSOC_REQUESTER assoc_req, WIFIENCAP $clientwifiencap, ACTIVESCAN $active, DEBUG 2 );

	  //all :: CompoundHandler("debug", "BRNAssocRequester InfrastructureClient", "2");
	  

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
			                      0/c0%f0, //De-Authentification
			                      -
          );


    mgt_cl[0]  //Association Request
    -> Discard;    

    mgt_cl[1]  //Association Response
//    -> Print("Bekomme Association Response")
    -> assoc_req
 //   -> Print("Sende Association Request")
    -> [0]output;

    mgt_cl[2]  //Reassociation Request
    -> Discard;

    mgt_cl[3]  //Reassociation Response
//    -> Print("Bekomme Reassociation Response")
    -> assoc_req;

    mgt_cl[4]  //Probe Request
    -> Discard;

    mgt_cl[5]  //Probe Response
//    -> PrintWifi("Bekomme Probe Response in den Beaconscanner")
    -> bs
    -> Discard;
    
    probe_req
    //-> Print("Send Probe",64)
    -> [0]output;

    mgt_cl[6]  //Beacon
//  -> PrintWifi("Bekomme Beacon: ")
    -> bs;

    mgt_cl[7]  //ATIM (Power Save)
    -> Discard;

    mgt_cl[8]  //Deassociation
//  -> Print("Bekomme deassoc",64)
    -> assoc_req;

    mgt_cl[9]  //Authentification
//    -> Print("bekomme AUTH")
    -> auth_req    
//    -> Print("Send AUTH ",128)
    -> [0]output;

    mgt_cl[10]  //De-Authentification
    -> Discard;

    mgt_cl[11]
//    -> Print("Unknown Managment-frames")
    -> Discard;
}
