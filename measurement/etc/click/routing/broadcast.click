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
  -> Print("NODENAME: BC: broadcast", TIMESTAMP true)
  -> [0]bcf;

  bc_clf[1]
  -> Print("NODENAME: BC: unicast", TIMESTAMP true)
  -> [0]bcr;

  input[1]
  -> Print("BRNin", TIMESTAMP true)
  -> bcr_clf::Classifier( 0/BRN_PORT_FLOODING,     //Flooding
                          0/BRN_PORT_BCASTROUTING, //BroadcastRouting
                          -  ); //other

  bcr_clf[0]
  -> [1]bcf;

  bcr_clf[1]
  -> [1]bcr;

  bcr_clf[2]
  -> Print("NODENAME: Unknown type in broadcast",TIMESTAMP true)
  -> Discard;

  input[2] -> [2]bcf;

  bcf[0]
  -> Print("NODENAME: Local Copy",TIMESTAMP true)
  -> bcrouting_clf::Classifier( 12/BRN_ETHERTYPE 14/BRN_PORT_BCASTROUTING,  //BrnBroadcastRouting
                                    - );

  bcrouting_clf[0]
  -> BRN2EtherDecap()
  -> Print("NODENAME: broadcastrouting",TIMESTAMP true)
  -> [1]bcr;

  bcrouting_clf[1]
  -> Print("NODENAME: SimpleFlood-Ether-OUT",TIMESTAMP true)
  -> [0]output;

  bcf[1]
  -> Print("NODENAME: Forward Copy",TIMESTAMP true)
  -> [1]output;

  bcr[0]
  -> Print("NODENAME: BCR: fin dest",TIMESTAMP true)
  -> [0]output;

  bcr[1]
  -> Print("NODENAME: Flood",TIMESTAMP true)
  -> [0]bcf;

  input[3]
  -> Classifier( 0/BRN_PORT_FLOODING )  //Flooding
  -> [3]bcf;

  input[4]
  -> [4]bcf;

}

#endif
