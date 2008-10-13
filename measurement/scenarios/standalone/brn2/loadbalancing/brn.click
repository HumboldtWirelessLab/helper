//LoadBalancer: get traffic from the client and decide, whether it should be handled locally or send to another nodeh
//		get also traffic from other nodes which goes to the client
//		has Linstat as parameter to get etx-values to other nodes; linkstat should be extended to send information about the DSL-Line
//		
//Loadbalancer: get traffic from remote-nodes(redirected by Loadbalancer) and send it to the Internet
//	        get traffic from the internet and decide whether it is for a local or a remote node 

wlan_out_queue :: NotifierQueue(50);

elementclass AccessPoint {
    INTERFACE $device, SSID $ssid, CHANNEL $channel, BEACON_INTERVAL $beacon_interval |

    BRNAddressInfo(ether_address $device:eth);
    winfo :: WirelessInfo(SSID $ssid, BSSID ether_address, CHANNEL $channel, INTERVAL $beacon_interval);
    rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);
    bs :: BeaconScanner(RT rates);

    input[0]
    -> mgt_cl :: Classifier(
          0/00%f0, //assoc req
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
    -> bs                    //BeaconScanner
    -> Discard; 

    mgt_cl[5]
    -> Discard;

    mgt_cl[6]
    -> OpenAuthResponder(WIRELESS_INFO winfo)
    -> [0]output;
}

rc :: BrnRouteCache(ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
lt :: BrnLinkTable(rc, STALE 500,  SIMULATE false, CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);
id :: NodeIdentity(eth0, eth0, eth0, lt);
rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);

link_stat :: BRNLinkStat(ETHTYPE 0x0a04, 
        NODEIDENTITY id, 
        PERIOD 3000,
        TAU 30000,
        //PROBES "2 60 12 60 2 1400 4 1400 11 1400 22 1400 12 1400 18 1400 24 1400 36 1400 48 1400 72 1400 96 1400",
        //ETT ett_metric,
        ETX etx_metric,
        PROBES "22 250",
        RT rates);


BRNAddressInfo(my_wlan eth0:eth);

nb_lst :: NeighborList(); // collect information about neighbors

//out_q_0 :: Null();          //wifi_out_queue does the job

BRNAddressInfo(my_vlan eth0:eth);

//ds :: BRNDS(id, nb_lst);

client_lst :: AssocList(id);
//client_ds :: ClientDS(eth0, vlan1, vlan2, vlan0, client_lst);

ap :: AccessPoint( INTERFACE eth0, SSID ##brn3##, CHANNEL 1, BEACON_INTERVAL 100);

// ----------------------------------------------------------------------------
// Link Metric
// ----------------------------------------------------------------------------

etx_metric :: BRNETXMetric(LT lt);

// ----------------------------------------------------------------------------
// Handling ath0-device
// ----------------------------------------------------------------------------
FromSimDevice(eth0,4096) //, PROMISC true
  -> Strip(14)
  -> FilterPhyErr()
//  -> Print("FromDevice", 100)
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> mgm_clf :: Classifier(0/00%0f, -); // management frames

mgm_clf[0] //handle mgmt frames
  -> ap
  -> SetTXRate(22) // ap beacons send at constant bitrate
  -> wlan_out_queue;

mgm_clf[1] //handle other frames (data)
  -> WifiDecap()
  -> clf_bcast :: Classifier(0/ffffffffffff, 0/000347708902, -); // broadcast & unicast packets

clf_bcast[0]
  -> protoclf :: Classifier(12/8086,              //brn-protocoll
			        12/8087,	      //loadbalance redirected request
			        12/8088,	      //loadbalance redirected reply
                           - );
//
// handle Unicast
//

clf_bcast[1]
  -> Print("For Client")
  -> Discard();
  

clf_bcast[2]                                      //Unicast
  -> Print("AP: Unicast (in): ",256)
  -> protoclf;



lbforeignflow :: LoadBalancerForeignFlowHandler(my_wlan);
lbredirect :: LoadBalancerRedirect(my_wlan, LINKSTAT link_stat);

lbforeignflow[1]
-> tonet::EtherDecap()
-> Print("AP: Packet to Net")
-> MarkIPHeader()
-> IPMirror()
-> Print("AP: Packet from Net")
-> [1]lbforeignflow;

//NO BRN
protoclf[1]
-> Print("AP: Got Packet from foreign Client")
-> [0]lbforeignflow[0]
-> Print("AP: Send Packet-Reply to foreign Client over neighbour AP")
-> WifiEncap(0x00, 0:0:0:0:0:0) // packet to brn peer node
-> wlan_out_queue;

protoclf[2]
-> Print("AP: Got Packet-Reply for my rederecded flow")
-> [1]lbredirect;

protoclf[3]                                       //simple packets (no brn) (only IP)
  -> Classifier(12/0800)                          // ip packet (don't handle IP-Packets in simulation -> Discard
  -> Print("AP: Got Client-packet: Redirect ??")
  -> lbredirect
  -> Print("AP: Ether Back to Client")
  -> WifiEncap(0x02, WIRELESS_INFO ap/winfo) 
  -> Print("AP: WIfi Back to Client")
  -> wlan_out_queue;

lbredirect[1]
-> Print("AP: Handle local")
-> tonet;


lbforeignflow[2]
-> [2]lbredirect;

lbredirect[2]
  -> Print("AP: Redirect Packet")
  -> WifiEncap(0x00, 0:0:0:0:0:0) // packet to brn peer node
  -> wlan_out_queue;

//BRN intern and other Clients

protoclf[0]                              //brn packets
  -> EtherDecap()
  -> nb_lst                              //know your neighbor
  -> brnclf :: Classifier(  0/06, //LinkProbe
                                     -        //other
                                   );

brnclf[0] //linkprobe
  -> SetTimestamp()
  -> link_stat
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0) // packet to brn peer node
  -> wlan_out_queue;

brnclf[1]
-> Discard();

  wlan_out_queue
  -> AddEtherNsclick()
//-> Print("ToSim")
  -> ToSimDevice(eth0);

filter[1]                                              //take a closer look at tx-annotated packets
  -> failures :: FilterFailures();

failures[0]
  -> Discard;

failures[1]
  -> WifiDupeFilter()
  -> Discard();
  
Script(
  wait 15,
  read lt.links
);

