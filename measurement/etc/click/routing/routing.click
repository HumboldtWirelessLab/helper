/* Routing */
#include "dsr.click"

elementclass ROUTING { ID $id, ETTHERADDRESS $ea, LT $lt, RC $rc, METRIC $metric, LINKSTAT $linkstat | 

  //lpr::LPRLinkProbeHandler(LINKSTAT $linkstat, ETXMETRIC $metric);
  routing::DSR($id, $lt, $rc, $metric);

  input[0]         //Ethernet
    -> [0]routing;

  input[1]         //BRN
    -> [1]routing;

  input[2]        //BRN-Feddback
    -> [2]routing;

  input[3]        //Overhear
    -> [3]routing;

  routing[0]      //Ethernet
    -> toMeAfterRouting::BRN2ToThisNode(NODEIDENTITY id);

  routing[1]      //BRN (Routing)
    -> SetEtherAddr(SRC $ea)
    -> routing_cnt::Counter()
    -> [0]output; //[0]device

  toMeAfterRouting[2]
    -> [1]output; //[1]device
  
  toMeAfterRouting[0]
    -> [2]output; //to Me

  toMeAfterRouting[1]
    -> [3]output; //broadcast

}
