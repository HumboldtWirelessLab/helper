elementclass ACCESS_POINT { DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel,
                           BEACON_INTERVAL $beacon_interval, LT $link_table, RATES $rates |

    assoclist :: BRN2AssocList(LINKTABLE $link_table);
    winfo :: WirelessInfo(SSID $ssid, BSSID $etheraddress, CHANNEL $channel, INTERVAL $beacon_interval);
    bs :: BeaconScanner(RT rates);

    input[0]
    -> mgt_cl :: Classifier( 0/00%f0, //assoc req
                             0/10%f0, //assoc resp
                             0/40%f0, //probe req
                             0/50%f0, //probe resp
                             0/80%f0, //beacon
                             0/a0%f0, //assoc
                             0/b0%f0, //disassoc
                                -  );

    mgt_cl[0]
//  -> Print("assocReq")
    -> BRN2AssocResponder(DEBUG 0, DEVICE $device, WIRELESS_INFO winfo,
                          RT rates, ASSOCLIST assoclist, RESPONSE_DELAY 0 )
    -> [0]output;

    mgt_cl[1]
//  -> Print("assocResp")
    -> Discard;

    mgt_cl[2]
//  -> Print("probereq")
    -> BRN2BeaconSource( WIRELESS_INFO winfo, RT rates,ACTIVE 1)
//  -> Print("proberesp")
    -> [0]output;

    mgt_cl[3]
//  -> Print("proberesp")
    -> Discard;

    mgt_cl[4]
//  -> Print("beacon")
    -> bs                    //BeaconScanner
    -> Discard; 

    mgt_cl[5]
//  -> Print("Dissas")
    -> Discard;

    mgt_cl[6]
//  -> Print("authReq")
    -> OpenAuthResponder(WIRELESS_INFO winfo)
    -> [0]output;
    
    mgt_cl[7]
//  -> Print("Unknow Managmentframe",10)
    -> Discard;
}
