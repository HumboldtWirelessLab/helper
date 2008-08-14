wlan_out_queue :: NotifierQueue(50);

// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN DSR packets from internal nodes
// input[2] - failed transmission of a BRN DSR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN DSR packets to internal nodes (BRN DSR protocol)

elementclass DSR {$DEVICE_1, $DEVICE_2, $DEVICE_3 |

  rc :: BrnRouteCache(ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
  lt :: BrnLinkTable(rc, STALE 500,  SIMULATE false, CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);
  id :: NodeIdentity($DEVICE_1, $DEVICE_2, $DEVICE_3, lt);
  brn_encap :: BRNEncap;
  dsr_decap :: DSRDecap(id);
  dsr_encap :: DSREncap(id);
  nb :: DstClassifier(id, client_lst);
  querier :: RouteQuerier(id, dsr_encap, brn_encap, dsr_decap);
  req_forwarder :: RequestForwarder(id, dsr_decap, dsr_encap, brn_encap, querier, client_lst, 15000);
  rep_forwarder :: ReplyForwarder(id, dsr_decap, querier, client_lst, dsr_encap);
  src_forwarder :: SrcForwarder(id, client_lst, dsr_encap, dsr_decap);
  err_forwarder :: ErrorForwarder(id, client_lst, dsr_encap, dsr_decap, querier, brn_encap);

  // ------------------
  // external packets
  // ------------------
  input[0]
  -> clf_bcast :: Classifier(0/ffffffffffff, -);     // broadcast & unicast packets

  clf_bcast[0]
  -> Discard;

  clf_bcast[1]
  -> nb;

  nb[0]                                                         // packet is for me
  -> [0]output;

  nb[1]                                                         // packet for associated client (external)
  -> [0]output;

  nb[2]                                                         // packet for internal nodes
  -> SetTimestamp()
  -> querier;

  querier[0]
  -> SetTimestamp()
  -> [1]output;                                             // rreq packets (broadcast)
  
  querier[1] 
  -> SetTimestamp()
  -> [0]src_forwarder;                                  // src routed packets (unicast)

  src_forwarder[0]
  -> [1]output;

  src_forwarder[1]
  -> [0]output;

  src_forwarder[2]
  -> tee_to_err_fwd :: Tee()
  -> Discard;                                                  //is for BRNiapp

  tee_to_err_fwd[1]
  -> [0]err_forwarder;

  // ------------------
  // internal packets
  // ------------------
  input[1]
  -> dsrclf :: Classifier( 6/01, //DSR_RREQ
                                   6/02, //DSR_RREP
                                   6/03, //DSR_RERR
                                   6/04, //DSR_SRC
                                 );

  dsrclf[0]
  -> req_forwarder[0]
  -> [1]output;

  req_forwarder[1]
  -> [0]rep_forwarder
  -> SetTimestamp()
  -> [1]output;

  dsrclf[1]
  -> [1]rep_forwarder;

  dsrclf[2]
  -> [1]err_forwarder
  -> [1]output;

  dsrclf[3]
  -> [1]src_forwarder;

  // ------------------
  // undeliverable packets
  // ------------------
  input[2]
  -> [0]err_forwarder;
}

rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);

link_stat :: BRNLinkStat(ETHTYPE 0x0a04, 
        NODEIDENTITY dsr/id, 
        PERIOD 3000,
        TAU 30000,
        //PROBES "2 60 12 60 2 1400 4 1400 11 1400 22 1400 12 1400 18 1400 24 1400 36 1400 48 1400 72 1400 96 1400",
        //ETT ett_metric,
        ETX etx_metric,
        PROBES "22 250",
        RT rates);


AddressInfo(my_wlan eth0:eth);

nb_lst :: NeighborList(); // collect information about neighbors

//------------------------------------------------------------------------------------------------------------------

elementclass DHCP_ARP { 

//dht: 
//input:       0: von DHT-Nodes           1: von services         2: DSR (BRN-Takeout)
//output:    0: zu DHT-Nodes             1: Services                2: zum DSR

  dhcp_server :: DHCPServer(my_wlan, 10.9.0.0/24, 10.9.0.1, 10.9.0.1, 192.168.2.3 ,"dhcp.brn.net","brn.net");
  arp :: Arp( 10.8.0.1, my_wlan );
  dht :: FalconDHT(my_wlan, link_stat, 10.9.0.0/24, 30000 , 10 , 50 , 25, FAKE_ARP 1 );
//dhcp_client :: DHCPRequester(10:10:10:10:01:00 , 10.9.0.2, 1 , 40100 , 400 );
//arpclient :: ARPClient( 10.9.20.1 , 10:10:10:10:00:f0 , 10.9.0.0, 256 , 40000 , 450 , 10 , 1 ,  5000, DEBUG 5 );

//Lines gen by script 


  dhcp_arp_clf :: Classifier (       12/0806 ,                            //arp
                                                 12/0800 23/11 36/0043,     //dhcp
                                                  0/07 ,                                 //brn
                                          - );

  dht_classifier :: Classifier ( 1/03 ,    //arp
                                           1/02 ,    //dhcp
                                           - );

  input[0]
    -> dhcp_arp_clf;

  input[1]
    -> [2]dht;

  dht[2]
    -> [3]output;

  dhcp_arp_clf[0]
    -> [0] arp;

  Idle()
  ->[0] output; 

  arp[0]
  -> Discard;
  
  Idle()
  -> [0]arp;
    
  dhcp_arp_clf[1]
      -> EtherDecap()	
      -> Align(4, 0)
      -> CheckIPHeader()
      -> IPClassifier(dst udp port 67 and src udp port 68)
      -> Strip(28) // strip ip and udp
    -> [0] dhcp_server;

 Idle()
//  -> dhcp_client
  -> dhcp_server
//  -> dhcp_client;
  -> Discard;

  dhcp_arp_clf[2]
    -> Strip(6)
    -> Print("From other DHT-Nodes", 60)
    -> [0]dht[0]
    -> Print("For other DHT-Nodes",60)
    -> dht_out_clf :: Classifier (0/ffffffffffff, -);

  dht_out_clf[0]
//    -> Print("out bc")
    -> [1]output;

  dht_out_clf[1]
    -> [2]output;


  dhcp_server [1] -> [1] dht;
  arp [1] -> [1] dht;
  dht [1] -> dht_classifier;

  dht_classifier[0] -> [1] arp;
  dht_classifier[1] -> [1] dhcp_server;
  dht_classifier[2] -> Discard;

  dhcp_arp_clf[3]
  -> Print("1_was dass: ",60)
  -> Discard;

// dhcp_client[1]
// -> Discard;

}

out_q_0 :: Null();          //wifi_out_queue does the job

// ----------------------------------------------------------------------------
// Integration of DSR
// ----------------------------------------------------------------------------

AddressInfo(my_vlan eth0:eth);
dsr :: DSR(eth0, eth0, eth0); // using DSR //schon weiter oben

ds :: BRNDS(dsr/id, nb_lst);

client_lst :: AssocList(dsr/id);
client_ds :: ClientDS(eth0, vlan1, vlan2, vlan0, client_lst);

// ----------------------------------------------------------------------------
// Link Metric
// ----------------------------------------------------------------------------

etx_metric :: BRNETXMetric(LT dsr/lt);

// ----------------------------------------------------------------------------
// Handling ath0-device
// ----------------------------------------------------------------------------
  FROMDEVICE
  -> Print("1_FromDevice",60,TIMESTAMP true)
  -> FilterPhyErr()
//-> Print("FromDevice")
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> mgm_clf :: Classifier(0/00%0f, -); // management frames

mgm_clf[0] //handle mgmt frames
  -> Discard;

mgm_clf[1] //handle other frames (data)
  -> WifiDecap()
  -> clf_bcast :: Classifier(0/ffffffffffff, -); // broadcast & unicast packets


//
//broadcast (ARP oder DHCP) nicht gut aber zum test
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//


dhcp_arp :: DHCP_ARP();

clf_bcast[0]
  ->   dhcp_arp_classifier :: Classifier (12/0806 ,                            // arp
                                                          12/0800 23/11 36/0043,     // dhcp
	 				        12/8086 14/07 15/07,         // dht
                                                          - );

dhcp_arp_classifier[0]
  -> dhcp_arp;

dhcp_arp_classifier[1]
  -> dhcp_arp;


dhcp_arp_classifier[2]
//  -> Print("BC form DHT-Node")
  -> EtherDecap()
  -> dhcp_arp;

dhcp_arp[0]  //to station (not exist in this simulation, so discard
-> Discard();

dhcp_arp[1]
 // -> Print("bd no   BRN-Encap",60)
 // -> BRNEtherEncap()
 // -> Print("bd with BRN-Encap",60)
  -> WifiEncap(0x00, 0:0:0:0:0:0) // packet to brn peer node
  -> wlan_out_queue;

dhcp_arp[2]
  ->[0]dsr;


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

dhcp_arp_classifier[3]
  -> protoclf :: Classifier(12/8086,              //brn-protocoll
                           - );

//
// handle Unicast
//

clf_bcast[1]                                      //Unicast
  -> Print("Unicast (in): ",256)
  -> protoclf;
    
//NO BRN

protoclf[1]                                       //simple packets (no brn) (only IP)
  -> Classifier(12/0800)                    // ip packet (don't handle IP-Packets in simulation -> Discard
  -> Discard();

//BRN intern and other Clients

protoclf[0]                           //brn packets
  -> EtherDecap()
  -> nb_lst                            //know your neighbor
  -> brnclf :: Classifier(0/01, //BrnSDP
                                   0/02, //BrnTFTP
                                   0/03, //BrnDSR
                                   0/04, //BrnBcast
                                   0/06, //LinkProbe
			     0/07, //DHT
                                     -     //other
                                   );

brnclf[0] // sdp 
-> Discard;

brnclf[1] // tftp
-> Discard;

brnclf[2] //dsr
  -> Print("1_BRN-clf: DSR: ",60)
  -> dht_take_out ::  Classifier( 0/0303 6/04 163/02 , - );                                        //0: brn src und dst (dsr)   6: dsr-type (src_route)    163: dsr payload (dht)  163 = 16 (HOP_COUNT) * 8 + 35 
  
  dht_take_out[0]
 // -> [1]dhcp_arp;
   -> Print("DSR (DHT)",60)
   -> [1]dsr;
  
  Idle
-> [1]dhcp_arp;

  dhcp_arp[3]
  -> Print("DSR",60)
  -> [1]dsr;
  
  dht_take_out[1]
  -> [1]dsr;

brnclf[3] //bcast
  -> Discard;

brnclf[4] //linkprobe
  -> SetTimestamp()
  -> link_stat
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
//  -> BRNEtherEncap()
  -> WifiEncap(0x00, 0:0:0:0:0:0) // packet to brn peer node
  -> wlan_out_queue;

brnclf[5] //dht
  -> dhcp_arp;

brnclf[6] //other
  -> [0]dsr;

 elementclass BrnInBrnClassifier                                                                                                                                                                                
  {                                                                                                                                                                                                              
    input[0]                                                                                                                                                                                                     
    -> brn_in_brn_clf :: Classifier(12/8086 14/03, 12/8086, -); // handle brn-in-brn                                                                                                                             
                                                                                                                                                                                                                 
    brn_in_brn_clf[0] // brn-in-brn with dsr                                                                                                                                                                     
    //-> Print("Got BRN-in-BRN with DSR, discarded to prevent loop")                                                                                                                                             
    -> Discard();                                                                                                                                                                                                
                                                                                                                                                                                                                 
    brn_in_brn_clf[1] // brn-in-brn without dsr                                                                                                                                                                  
    //-> Print("Got BRN-in-BRN")                                                                                                                                                                                 
    -> [1]output;                                                                                                                                                                                                
                                                                                                                                                                                                                 
    brn_in_brn_clf[2] // other, send to output 0                                                                                                                                                                 
    -> [0]output;                                                                                                                                                                                                
  } 

        
dsr[0] //for an assoc client
 -> brn_in_brn_clf :: BrnInBrnClassifier
  -> Print("1_for_client: ", 60)
  -> dst_clf :: DstClassifier(dsr/id, client_lst);

  brn_in_brn_clf[1]                                                                                                                                                                                              
  -> EtherDecap()                                                                                                                                                                                                
  -> brnclf; 

dst_clf[1]                                           // for assoc client
  -> client_ds;

client_ds[0]                                        //don't support Clients, so discard
  -> Discard;

client_ds[1]
  -> Discard; //vlan1

client_ds[2]
  -> Discard; //vlan2

client_ds[3]
  -> Discard; //vlan0 (debug)

dst_clf[0]
  -> Classifier(12/0800) // ip packet
  -> Align(4, 0)
  -> CheckIPHeader(14)
  -> tohost_cl :: IPClassifier(dst net 10.9.0.1 mask 255.255.0.0,
        -);

dst_clf[2]
  -> Discard;

tohost_cl[0]
  -> EtherDecap()
  -> CheckIPHeader
  -> ICMPPingResponder
  -> BRNEtherEncap
  -> [0]dsr; // back on route

arp_tab :: ARPTable();

tohost_cl[1] // for the tun device
-> Discard();

dsr[1]                                               //for an other internal node; make use of ds
  -> ds;

ds[0] -> out_q_0;
ds[1] -> Discard;
ds[2] -> Discard;

out_q_0
  -> Print("dam",60)
//-> SetTXRate(22)
//-> SetEtherAnno()
//  -> BRNEtherEncap()
//-> SetEtherAnno()
  -> WifiEncap(0x00, 0:0:0:0:0:0)                     // sollte das WDS Packet erzeugen mit Hilfe eines Parameters
  -> wlan_out_queue
  -> SetTXRate(22)
  -> SetTimestamp()
  -> Print("ToSim_1 ------ :",TIMESTAMP true)
  -> TODEVICE;

filter[1]                                              //take a closer look at tx-annotated packets
  -> failures :: FilterFailures();

failures[0]
  -> Discard;

failures[1]
  -> WifiDupeFilter()
  -> mgm_clf2 :: Classifier(0/00%0f, -);               // management frames

mgm_clf2[0]                     //handle mgmt frames
  -> Discard;

mgm_clf2[1]                     //other frames
  -> WifiDecap()
  -> Classifier(12/8086)   //handle only brn protocol
  -> EtherDecap()
  -> [2]dsr;

Script(
  wait 20,
  read dsr/lt.links,
  wait 15,
  read dsr/lt.links,
  read dhcp_arp/dht.routing_info
);
