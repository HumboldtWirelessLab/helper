#ifndef __BROADCASTFLOODING_CLICK__
#define __BROADCASTFLOODING_CLICK__

//input[0]: From Src (who wants to send a broadcats), i.e. the originator of the flooding
//input[1]: Received from other brn node
//input[2]: Errors (not used)
//input[3]: Passiv (overhear/monitor)
//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

elementclass BROADCASTFLOODING {ID $id, LT $lt |

#ifdef PRO_FL
  flp::ProbabilityFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC 200);
#else
  flp::SimpleFlooding();
#endif
  
  fl::Flooding(FLOODINGPOLICY flp);

#ifdef BCAST2UNIC
  unicfl :: UnicastFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC 200, CANDSELECTIONSTRATEGY 1, DEBUG 2);
#endif

  input[0]
  -> [0]fl;

  input[1]
  -> BRN2Decap()
  -> [1]fl;

  input[2]
  -> Discard;

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

  input[3]
  -> BRN2Decap()
  -> [1]fl;

}

#endif
