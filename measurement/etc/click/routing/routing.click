/* Routing */
// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN packets from internal nodes
// input[2] - failed transmission of a BRN packet (broken link) from ds
// input[3] - Passiv (overhear/monitor)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN packets to internal nodes (BRN  protocol)
// [2]output - to me
// [3]output - broadcast

#include "brn/brn.click"
#include "dsr.click"
#include "batman.click"
#include "broadcast.click"
#include "geor.click"
#include "dart.click"
#include "hawk.click"

#ifdef ROUTINGDART
#define DHTROUTING
#endif

#ifdef ROUTINGHAWK
#define DHTROUTING
#endif

#ifdef DHTROUTING

elementclass ROUTING { ID $id, ETTHERADDRESS $ea, LT $lt, METRIC $metric, LINKSTAT $linkstat, DHT $dht | 

#else

elementclass ROUTING { ID $id, ETTHERADDRESS $ea, LT $lt, METRIC $metric, LINKSTAT $linkstat | 

#endif

routingtable::BrnRoutingTable(DEBUG 2, ACTIVE true, DROP 0 /* 1/20 = 5% */, SLICE 500 /* 500ms */, TTL 10 /* 10*500ms */);
routingalgo::Dijkstra(NODEIDENTITY $id, LINKTABLE $lt, MIN_LINK_METRIC_IN_ROUTE 6000, MAXGRAPHAGE 30000, DEBUG 2);
routingmaint::RoutingMaintenance(NODEIDENTITY $id, LINKTABLE $lt, ROUTETABLE routingtable, ROUTINGALGORITHM routingalgo, DEBUG 2);

#ifdef ROUTINGDSR
#ifdef DSRLPR
  lpr::LPRLinkProbeHandler(LINKSTAT $linkstat, ETXMETRIC $metric);
#endif

  routing::DSR($id, $lt, $metric, routingmaint);

#define BRN_PORT_ROUTING BRN_PORT_DSR
#define HAVEROUTING
#else
#ifdef ROUTINGBATMAN

  routing::BATMAN($id, $lt);

#define BRN_PORT_ROUTING BRN_PORT_BATMAN
#define HAVEROUTING
#else
#ifdef ROUTINGGEOR

  routing::GEOR($id, $lt, $linkstat);

  Script(
    write routing/gps.cart_coord NODEPOSITIONX NODEPOSITIONY NODEPOSITIONZ,
  );

#define BRN_PORT_ROUTING BRN_PORT_GEOROUTING
#define HAVEROUTING
#else
#ifdef ROUTINGBROADCAST

  routing::BROADCAST(ID $id, LT $lt);

#define BRN_PORT_ROUTING BRN_PORT_BCASTROUTING
#define HAVEROUTING
#else

dht::DHT_FALCON(ETHERADDRESS deviceaddress, LINKSTAT device_wifi/link_stat, STARTTIME 30000, UPDATEINT 1000, DEBUG 2);
dhtstorage::DHT_STORAGE( DHTROUTING dht/dhtrouting, DEBUG 2 );
routing::HAWK(id, dht/dhtroutingtable, dhtstorage/dhtstorage, dht/dhtrouting, lt, dht/dhtlprh, dht, 2);


#endif
#endif
#endif
#endif

#ifndef HAVEROUTING
#define ROUTINGDSR
  routing::DSR($id, $lt, $metric, routingmaint);
#define BRN_PORT_ROUTING BRN_PORT_DSR
#endif

  input[0]         //Ethernet
    -> [0]routing;

  input[1]         //BRN
    -> [1]routing;

  input[2]        //BRN-Feedback (Failed)
    -> [2]routing;

  input[3]        //Overhear
    -> [3]routing;

  input[4]        //BRN-Feedback (success)
    -> [4]routing;

  routing[0]      //Ethernet
    -> toMeAfterRouting::BRN2ToThisNode(NODEIDENTITY id);

  routing[1]      //BRN (Routing)
#ifdef ROUTINGDSR
    -> SetEtherAddr(SRC $ea)
#endif
    -> routing_cnt::Counter()
    -> [0]output; //[0]device

  toMeAfterRouting[2]
    -> [1]output; //[1]device
  
  toMeAfterRouting[0]
    -> [2]output; //to Me

  toMeAfterRouting[1]
    -> [3]output; //broadcast

}
