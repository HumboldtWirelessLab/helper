#ifndef __BROADCASTFLOODING_CLICK__
#define __BROADCASTFLOODING_CLICK__

//input[0]: From Src (who wants to send a broadcats), i.e. the originator of the flooding
//input[1]: Received from other brn node
//input[2]: txfeedback: failed transmission of a BRN BroadcastRouting  packet (broken link) from ds
//input[3]: Passiv (overhear/monitor)
//input[4]: txfeedback: successful transmission of a BRN BroadcastRouting  packet

//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

#ifndef FLOODING_DEBUG
#define FLOODING_DEBUG 2
#endif

#ifndef FLOODING_MAXNBMETRIC
#define FLOODING_MAXNBMETRIC 200
#endif

elementclass BROADCASTFLOODING {ID $id, LT $lt |

  fl_helper::FloodingHelper(LINKTABLE $lt, MAXNBMETRIC FLOODING_MAXNBMETRIC, DEBUG FLOODING_DEBUG);

#ifdef PRO_FL
#ifndef PROBABILITYFLOODING_FWDPROBALILITY
#define PROBABILITYFLOODING_FWDPROBALILITY 90
#endif
  flp::ProbabilityFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC FLOODING_MAXNBMETRIC, MINNEIGHBOURS 3, FWDPROBALILITY PROBABILITYFLOODING_FWDPROBALILITY, DEBUG FLOODING_DEBUG);
#else
#ifdef MPR_FL
  flp::MPRFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC 200, DEBUG FLOODING_DEBUG);
#else
  flp::SimpleFlooding();
#endif
#endif

  fl_passive_ack::FloodingPassiveAck(NODEIDENTITY $id, FLOODINGHELPER fl_helper, DEFAULTRETRIES 2, DEFAULTTIMEOUT 20, DEBUG 4);

  fl::Flooding(NODEIDENTITY $id, FLOODINGPOLICY flp, FLOODINGPASSIVEACK fl_passive_ack, DEBUG FLOODING_DEBUG);

#ifdef BCAST2UNIC

#ifndef BCAST2UNIC_STRATEGY
#define BCAST2UNIC_STRATEGY 1
#endif

  unicfl :: UnicastFlooding(NODEIDENTITY $id, FLOODING fl, FLOODINGHELPER fl_helper, CANDSELECTIONSTRATEGY BCAST2UNIC_STRATEGY, DEBUG FLOODING_DEBUG);
#endif

  routing_peek::FloodingRoutingPeek(DEBUG 4);

  input[0]  //to be send
  -> [0]fl;

  input[1]  //from brn
  -> Print("Plain: ",200)
  -> routing_peek
  -> BRN2Decap()
  -> [1]fl;

  input[2]  //txfeedback failure
  -> BRN2Decap()
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
  //-> Print("Flooding. Passive overhear",TIMESTAMP true)
  -> BRN2Decap()
  -> [4]fl;

  input[4] //txfeedback success
  //-> Print("FloodFeedback")
  -> BRN2Decap()
  -> [3]fl;

}

#endif
