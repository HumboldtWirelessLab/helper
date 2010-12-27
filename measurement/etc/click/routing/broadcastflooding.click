//input[0]: From Src (who wants to send a broadcats), i.e. the originator of the flooding
//input[1]: Received from other brn node
//input[2]: Errors (not used)
//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

elementclass BROADCASTFLOODING {$ID, $ADDRESS, $LT |

  flp::SimpleFlooding();
//flp::ProbabilityFlooding(LINKSTAT $LT);
  fl::Flooding(FLOODINGPOLICY flp, ETHERADDRESS $ADDRESS);

#ifdef BCAST2UNIC
  ucastrw :: UnicastFlooding(NODEIDENTITY me, LINKSTAT $LT, MAXNBMETRIC 200, CANDSELECTIONSTRATEGY 1, DEBUG 4);
#endif

  input[0]
  -> [0]fl;

  input[1]
#ifdef BCAST2UNIC
  // received from other brn node
  [0]ucastrw
#endif
  -> BRN2Decap()
  -> [1]fl;

  input[2]
  -> Discard;

  fl[0]
  -> [0]output;

  fl[1]
  -> BRN2EtherEncap(USEANNO true) 
//-> Print("SimpleFlood-Ether-OUT")
#ifdef BCAST2UNIC
  // transmit to other brn nodes
  [0]ucastrw
#endif
  -> [1]output;

}
