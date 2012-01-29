#ifndef __ACCESS_POINT_CLICK__
#define __ACCESS_POINT_CLICK__

//output:
//  0: mgt
//  1: data received
//  2: data send
//
//input::
//  0: mgt
//  1: data received
//  2: data send

elementclass ACCESS_POINT { DEVICE $device, ETHERADDRESS $etheraddress, SSID $ssid, CHANNEL $channel,
#ifdef VLAN_ENABLE
                           BEACON_INTERVAL $beacon_interval, LT $link_table, RATES $rates, VLANTABLE $vlt |
#else
                           BEACON_INTERVAL $beacon_interval, LT $link_table, RATES $rates |
#endif

    assoclist :: BRN2AssocList(LINKTABLE $link_table);
    winfo :: WirelessInfo(SSID $ssid, BSSID $etheraddress, CHANNEL $channel, INTERVAL $beacon_interval);
    bs :: BRN2BeaconScanner(RT rates);

#ifdef VLAN_ENABLE
    wil :: BRN2WirelessInfoList();
    assoc_resp::BRN2AssocResponder(DEBUG 0, DEVICE $device, WIRELESS_INFO winfo, RT rates, ASSOCLIST assoclist, RESPONSE_DELAY 0, WIRELESSINFOLIST wil, VLANTABLE $vlt )
    beacon_src::BRN2BeaconSource( WIRELESS_INFO winfo, RT rates, ACTIVE 1, WIRELESSINFOLIST wil)
#else
    assoc_resp::BRN2AssocResponder(DEBUG 0, DEVICE $device, WIRELESS_INFO winfo, RT rates, ASSOCLIST assoclist, RESPONSE_DELAY 0 )
    beacon_src::BRN2BeaconSource( WIRELESS_INFO winfo, RT rates, ACTIVE 1, HEADROOM 96)
#endif

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
    -> assoc_resp
    -> [0]output;

    mgt_cl[1]
//  -> Print("assocResp")
    -> Discard;

    mgt_cl[2]
//  -> Print("probereq")
    -> beacon_src
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
    
    input[1]          //from client, check whether it is a client , set VLAN, ....
    -> WifiDecap()
    -> [1]output;
    
    input[2]          //to client, use right encap, check whether it is a client, check VLAN, ....
     -> fromNodetoStation::BRN2ToStations(ASSOCLIST assoclist);

    fromNodetoStation[0]  //For Station
    -> clientwifi::WifiEncap(0x02, WIRELESS_INFO winfo)
    -> [2]output;

    fromNodetoStation[1]  //Broadcast
    -> clientwifi;

    fromNodetoStation[2]  //For Unknown
    -> Discard;

}

#endif
