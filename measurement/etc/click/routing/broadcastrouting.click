#include "routing/broadcastroutingcore.click"

//input[0]: From Src (who wants to send a broadcats)
//input[1]: Received from brn node
//input[2]: Errors (not used)
//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

elementclass BROADCASTROUTING {$ID, $ADDRESS, $LST |

  flp::SimpleFlooding();
//flp::ProbabilityFlooding(LINKSTAT $LST);
  sfl::Flooding(FLOODINGPOLICY flp, ETHERADDRESS $ADDRESS);
  
  bcr::BROADCASTROUTINGCORE(id,deviceaddress);
  
  input[0]
  -> bc_clf::Classifier( 0/ffffffffffff,
                              -       );
                              
  bc_clf[0]
//-> Print("Receive broadcast")
  -> [0]sfl;
  
  bc_clf[1]
//-> Print("Receive unicast")
  -> [0]bcr;
     
  input[1]
  -> BRN2Decap()
  -> [1]sfl;
 
  sfl[0]
//-> Print("Local Copy")
  -> bcrouting_clf::Classifier( 12/8086 14/BRN_PORT_BCASTROUTING,  //BrnBroadcastRouting
                                    - );
  
  bcrouting_clf[0]
  -> BRN2EtherDecap()
//-> Print("broadcastrouting")
  -> [1]bcr;

  bcrouting_clf[1]                    
//-> Print("SimpleFlood-Ether-OUT")
  -> [0]output;

  sfl[1]
//-> Print("Forward Copy")
  -> BRN2EtherEncap(USEANNO true) 
  -> [1]output;
  
  bcr[0]
  -> [0]output;
  
  bcr[1]
//-> Print("Flood")
  -> [0]sfl;

  input[2]
  -> Discard;

  Idle
  -> [2]bcr;
}
