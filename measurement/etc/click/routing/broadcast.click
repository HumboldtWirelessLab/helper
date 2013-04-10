#ifndef __BROADCAST_CLICK__
#define __BROADCAST_CLICK__

#include "routing/broadcastflooding.click"
#include "routing/broadcastrouting.click"


//input[0]: From Src (broadcast/unicast)
//input[1]: Received from brn node
//input[2]: Errors (not used)
//input[3]: Passiv (overhear)
//input[4]: txfeedback: successful transmission of a BRN BroadcastRouting  packet
//[0]output: Local copy ()
//[1]output: To other brn nodes

elementclass BROADCAST {ID $id, LT $lt |

  bcf::BROADCASTFLOODING(ID $id, LT $lt);
  bcr::BROADCASTROUTING(ID $id);

  input[0]
  -> bc_clf::Classifier( 0/ffffffffffff,
                              -       );

  bc_clf[0]
  //-> Print("BC: broadcast")
  -> [0]bcf;

  bc_clf[1]
  //-> Print("BC: unicast")
  -> [0]bcr;

  input[1]
  -> bcr_clf::Classifier( 0/BRN_PORT_FLOODING,     //Flooding
                          0/BRN_PORT_BCASTROUTING, //BroadcastRouting
                          -  ); //other

  bcr_clf[0]
  -> [1]bcf;

  bcr_clf[1]
  -> [1]bcr;

  bcr_clf[2]
  -> Print("Unknown type in broadcast")
  -> Discard;


  input[2]
  -> Discard;


  bcf[0]
  //-> Print("Local Copy")
  -> bcrouting_clf::Classifier( 12/BRN_ETHERTYPE 14/BRN_PORT_BCASTROUTING,  //BrnBroadcastRouting
                                    - );

  bcrouting_clf[0]
  -> BRN2EtherDecap()
  //-> Print("broadcastrouting")
  -> [1]bcr;

  bcrouting_clf[1]
  //-> Print("SimpleFlood-Ether-OUT")
  -> [0]output;

  bcf[1]
  //-> Print("Forward Copy")
  -> [1]output;

  bcr[0]
  -> [0]output;

  bcr[1]
  //-> Print("Flood")
  -> [0]bcf;

  Idle -> [2]bcr;
  Idle -> [2]bcf;
  Idle -> [3]bcf;
  Idle -> [4]bcf;

  input[3]
  -> overhear_bcr_clf::Classifier( 0/BRN_PORT_FLOODING,  //Flooding
                                                   -  ); //other

  overhear_bcr_clf
  -> [3]bcf;

  overhear_bcr_clf[1]
  -> Discard;

  input[4] -> Discard;

}

#endif
