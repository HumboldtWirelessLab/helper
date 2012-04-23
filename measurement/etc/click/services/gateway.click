/*
 * Gateway Service in Click
 */

/* Parameter:
 * ==========
 * - ETHER_ADDR               := ether address used for communication
 * - LINKTABLE                := linktable used by routing
 * - UPDATE_GATEWAYS_INTERVAL := interval (in s) to update list of gateways
 * - UPDATE_DHT_INTERVAL      := interval (in s) to update this node in dht
 * - PREFIX                   := networks prefix
 * - SERVICE_IP               := service IP
 *
 */

/* In- and Output ports:
 * =====================
 *  - input[0]        <- 802.3 IP frames (to Gateway Service)
 *  - input[1]        <- 802.3 BRN Gateway
 *  - input[2]        <- 802.3 to local gateway (used if this node is a gateway)
 *  - input[3]        <- 802.3 from local gateway
 *  - [0]output       -> 802.3 IP frames (from Gateway Service)
 *  - [1]output       -> 802.3 IP frames to chosen gateway
 *  - [2]output       -> 802.3 to local device
 *  - [3]output       -> 802.3 BRN Gateway feedback packet to orginator
 */

elementclass Gateway {
    ETHER_ADDR $my_wlan,
    ROUTINGMAINTENANCE $routingmaint,
    UPDATE_GATEWAYS_INTERVAL $up_gws,
    UPDATE_DHT_INTERVAL $up_gw,
    PREFIX $addr_prefix,
    SERVICE_IP $service_ip,
    DHTSTORAGE $dhtstorage,
    |

    // stores clients IP/MAC combination
    mac_ip :: ARPTable();
    table :: ARPTable();
    localsolve :: ARPTable();
    clients :: StoreIPEthernet(mac_ip)
    setgwflow :: BRNSetGatewayOnFlow(gateway, flows, mac_ip, buffer, $addr_prefix, $routingmaint); // implements AggregateListener
    buffer :: BRNPacketBuffer(setgwflow, 50);

    gateway :: BRNGateway($my_wlan, setgwflow, UPDATE_GATEWAYS_INTERVAL $up_gws, UPDATE_DHT_INTERVAL $up_gw,DHTSTORAGE $dhtstorage);

    ///////
    // generate ICMP error
    ///////
    icmp_error2client :: Null
    -> StoreIPEthernet(table)
    -> BRN2EtherDecap()
    -> udp :: IPClassifier(udp, -)
    // answer UDP with port unreachable
    -> ICMPError($service_ip, unreachable, port)
    -> resolve :: ResolveEthernet($my_wlan, table)
    -> paint :: CheckPaint(0)
    // no gateway known
    -> [0]output;

    udp[1]
    // anwser everything else with host unreachable
    -> ICMPError($service_ip, unreachable, host)
    -> resolve;

    // remote gateway failed
    paint[1]
    -> paint2 :: CheckPaint(1)
    -> encap :: BRNGatewayEncap(gateway);

    paint2[1]
    -> Print("BOGUS - Should never happen")
    -> IPPrint()
    -> Discard;


    //////
    // packets from clients to Internet
    //////
    input[0]
    -> SetTimestamp()
    -> StoreIPEthernet(localsolve) //robert
    -> CheckIPHeader(14)
    -> from_clients :: IPClassifier(udp && dst port 1194, tcp or udp, -)   // pass criteria for flow and non-flow packets
    -> setgw :: BRNSetGateway(gateway, $routingmaint) // non-flow packets
    -> [1]output;

    from_clients[2] // also non-flow
    -> setgw; 

    // no gateway known
    setgw[1]
    -> Print("No gateway known")
    // generate ICMP error
    -> Paint(0) // for identification
    -> icmp_error2client;


    from_clients[1] // flow packets
    //-> IPPrint("TO FLOW")
    -> flows :: AggregateIPFlows(TCP_TIMEOUT 60, TCP_DONE_TIMEOUT 10, UDP_TIMEOUT 60, ICMP false)
    -> direction :: IPClassifier(src $addr_prefix, -) // look only for our client for a gateway; not the reverse flow's packets
    -> clients
    -> buffer
    -> setgwflow
    -> [1]output;
	
    flows[1]
    -> Print("BOGUS - Should never happen")
    -> IPPrint()
    -> Discard;

    // no gateway known
    setgwflow[1]
    -> Print("No gateway known")
    // generate ICMP error
    -> Paint(0) // for identification
    -> icmp_error2client;


    //////
    // packets from Internet to clients
    //////
    input[1]
    //-> Print("Internet to Client")
    -> decap :: BRNGatewayDecap(gateway, DEBUG 2)
    //-> Print("flow packets have to pass AggregateIPFlows")
    -> CheckIPHeader(0)
    //-> Print("To Clients")
    -> to_clients :: IPClassifier(udp && src port 1194, tcp or udp or icmp type unreachable, -)
    -> [0]output;
    
    // send flow packet to flows (used for tracking)
    to_clients[1]
    //-> IPPrint("to Client: TO FLOW")
    -> flows;

    // ... but send them only to flow (not to choose a gateway)
    direction[1]
    //-> IPPrint("Reverse packets")
    -> ResolveEthernet($my_wlan, localsolve)
    -> [0]output;

    to_clients[2]
    -> [0]output;

    ///////
    // packets to Internet (this host was chosen as a Internet gateway)
    ///////
    input[2]
    //-> Print(" Packet to Internet ")
    -> before_local_gw :: IPClassifier(udp && src port 1194, tcp or udp, -)
    // supercise packet (this node may not a gateway be anymore)
    -> [1]gws :: BRNGatewaySupervisor(gateway);

    before_local_gw[2]
    -> [1]gws;

    before_local_gw[1]
    -> [0]gws;

    // passed supervisor
    gws
    //-> Print(" TO INTERNET ")
    //-> IPPrint
    -> [2]output;
    
    ///////
    // packet from local chosen gateway
    ///////
    input[3]
    //-> Print
    -> encap
    //-> Print
    -> [3]output;
    
    //
    // remote gateway failed
    //
    // failed supervisor - non-flow
    gws[1]
    //-> Print("Failed sending to this gateway, but is non-flow; Try again")
    -> from_clients;

    // failed supervisor - flow
    gws[2]
    // flow packet, but this node is no gateway
    // sending ICMP error
    -> Paint(1) // for identification
    -> icmp_error2client;


    //input[5]
    Idle
    -> [1]setgwflow;
    //input[6]
    Idle
    -> [2]setgwflow[2]
    -> Discard;
    //-> [5]output;
   
    //all :: CompoundHandler("debug",
    //                       "BRNGatewayEncap BRNGatewayDecap
    //                        BRNGatewaySupervisor BRNSetGatewayOnFlow
    //                        BRNGateway BRNSetGateway BRNPacketBuffer",
    //                       "2");
}
