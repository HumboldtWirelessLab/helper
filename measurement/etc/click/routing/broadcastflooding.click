#ifndef __BROADCASTFLOODING_CLICK__
#define __BROADCASTFLOODING_CLICK__

//input[0]: From Src (who wants to send a broadcats), i.e. the originator of the flooding
//input[1]: Received from other brn node
//input[2]: txfeedback: failed transmission of a BRN BroadcastRouting  packet (broken link) from ds
//input[3]: Passiv (overhear/monitor)
//input[4]: txfeedback: successful transmission of a BRN BroadcastRouting  packet (broken link) from ds

//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

elementclass BROADCASTFLOODING {ID $id, LT $lt |

#ifdef PRO_FL
  flp::ProbabilityFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC 200);
#else
  flp::SimpleFlooding();
#endif

  fl::Flooding(NODEIDENTITY $id, FLOODINGPOLICY flp, DEBUG 2);

#ifdef BCAST2UNIC
  unicfl :: UnicastFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC 200, CANDSELECTIONSTRATEGY 1, DEBUG 2);
#endif

  input[0]  //to be send
  -> [0]fl;

  input[1]  //from brn
  -> BRN2Decap()
  -> [1]fl;

  input[2]  //txfeedback failure
  -> [2]fl;

  fl[0]
  -> [0]output;

  fl[1] 
  -> BroadcastMultiplexer(NODEIDENTITY $id, USEANNO true)
  -> BRN2EtherEncap(USEANNO true) 
  //-> Print("BroadcastMultiplexer out")
#ifdef BCAST2UNIC
  -> unicfl                                                // transmit to other brn nodes
#endif
  -> [1]output;

  input[3] //passive
  -> Print("Flooding. Passive overhear",TIMESTAMP true)
  -> Discard;
  
  input[4] //txfeedback success
  -> BRN2Decap()
  -> [3]fl;

}

#endif
