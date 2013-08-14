#ifndef __BROADCASTFLOODING_CLICK__
#define __BROADCASTFLOODING_CLICK__

//input[0]: From Src (who wants to send a broadcats), i.e. the originator of the flooding
//input[1]: Received from other brn node
//input[2]: txfeedback: failed transmission of a BRN BroadcastRouting  packet (broken link) from ds
//input[3]: Passiv (overhear/monitor)
//input[4]: txfeedback: successful transmission of a BRN BroadcastRouting  packet

//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes
//[2]output - Feedback packets for upper layer

#ifndef FLOODING_DEBUG
#define FLOODING_DEBUG 2
#endif

#ifndef FLOODING_MAXNBMETRIC
#define FLOODING_MAXNBMETRIC 500
#endif

elementclass BROADCASTFLOODING {ID $id, LT $lt |

  fl_helper::FloodingHelper(LINKTABLE $lt, MAXNBMETRIC FLOODING_MAXNBMETRIC, CACHETIMEOUT 1000000, DEBUG FLOODING_DEBUG);

#ifdef PRO_FL
#ifndef PROBABILITYFLOODING_FWDPROBALILITY
#define PROBABILITYFLOODING_FWDPROBALILITY 90
#endif
  flp::ProbabilityFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC FLOODING_MAXNBMETRIC, MINNEIGHBOURS 3, FWDPROBALILITY PROBABILITYFLOODING_FWDPROBALILITY, DEBUG FLOODING_DEBUG);
#else
#ifdef MPR_FL

#ifndef MPR_LF_NBMETRIC
#define MPR_LF_NBMETRIC 500
#endif

  flp::MPRFlooding(NODEIDENTITY $id, LINKTABLE $lt, MAXNBMETRIC MPR_LF_NBMETRIC, DEBUG FLOODING_DEBUG);
#else
  flp::SimpleFlooding();
#endif
#endif

#ifndef FLOODING_PASSIVE_ACK_RETRIES
#define FLOODING_PASSIVE_ACK_RETRIES 2
#endif

#ifndef BCAST_RNDDELAYQUEUE_MINDELAY
#define BCAST_RNDDELAYQUEUE_MINDELAY 1
#endif

#ifndef BCAST_RNDDELAYQUEUE_MAXDELAY
#define BCAST_RNDDELAYQUEUE_MAXDELAY 20
#endif

  fl_passive_ack::FloodingPassiveAck(NODEIDENTITY $id, FLOODINGHELPER fl_helper, DEFAULTRETRIES FLOODING_PASSIVE_ACK_RETRIES, DEFAULTTIMEOUT BCAST_RNDDELAYQUEUE_MAXDELAY, DEBUG FLOODING_DEBUG);

  fl::Flooding(NODEIDENTITY $id, FLOODINGPOLICY flp, FLOODINGPASSIVEACK fl_passive_ack, DEBUG FLOODING_DEBUG);

#ifdef BCAST2UNIC

#ifndef BCAST2UNIC_STRATEGY
#define BCAST2UNIC_STRATEGY 0
#endif
#ifndef BCAST2UNIC_PRESELECTION_STRATEGY
#define BCAST2UNIC_PRESELECTION_STRATEGY 0
#endif
#ifndef BCAST2UNIC_REJECTONEMPTYCS
#define BCAST2UNIC_REJECTONEMPTYCS true
#endif
#ifndef BCAST2UNIC_UCASTPEERMETRIC
#define BCAST2UNIC_UCASTPEERMETRIC 0
#endif
#ifndef BCAST2UNIC_FORCERESPONSIBILITY
#define BCAST2UNIC_FORCERESPONSIBILITY false
#endif
#ifndef BCAST2UNIC_USEASSIGNINFO
#define BCAST2UNIC_USEASSIGNINFO false
#endif

  unicfl :: UnicastFlooding(NODEIDENTITY $id, FLOODING fl, FLOODINGHELPER fl_helper, PRESELECTIONSTRATEGY BCAST2UNIC_PRESELECTION_STRATEGY, REJECTONEMPTYCS BCAST2UNIC_REJECTONEMPTYCS, CANDSELECTIONSTRATEGY BCAST2UNIC_STRATEGY, UCASTPEERMETRIC BCAST2UNIC_UCASTPEERMETRIC, FORCERESPONSIBILITY BCAST2UNIC_FORCERESPONSIBILITY, USEASSIGNINFO BCAST2UNIC_USEASSIGNINFO, DEBUG FLOODING_DEBUG);

#endif
#ifndef FLOODING_LASTNODES_PP
#define FLOODING_LASTNODES_PP 3
#endif

#ifndef BCAST_E2E_RETRIES
#define BCAST_E2E_RETRIES 0
#endif
#ifndef BCAST_E2E_TIMEOUT
#define BCAST_E2E_TIMEOUT 500
#endif
#ifndef BCAST_E2E_TIMETOLERANCE
#define BCAST_E2E_TIMETOLERANCE 20
#endif

  fl_piggyback::FloodingPiggyback(NODEIDENTITY $id, FLOODING fl,  FLOODINGHELPER fl_helper, LASTNODESPERPKT FLOODING_LASTNODES_PP, DEBUG FLOODING_DEBUG);

  routing_peek::FloodingRoutingPeek(DEBUG FLOODING_DEBUG);

  input[0]  //to be send
  -> e2eretry::FloodingEnd2EndRetry(DEFAULTRETRIES BCAST_E2E_RETRIES, DEFAULTTIMEOUT BCAST_E2E_TIMEOUT, TIMETOLERANCE BCAST_E2E_TIMETOLERANCE, DEBUG FLOODING_DEBUG)
  -> [0]fl;

  input[1]  //from brn
  //-> Print("Plain: ",200)
  -> routing_peek
  -> BRN2Decap()
  -> [1]fl;

  input[2]  //txfeedback failure
  -> BRN2Decap()
  -> [2]fl;

  fl[0]
  -> [0]output;

  fl[1]
#ifdef SIMULATION
  -> rdq::RandomDelayQueue(MINDELAY BCAST_RNDDELAYQUEUE_MINDELAY, MAXDELAY BCAST_RNDDELAYQUEUE_MAXDELAY, DIFFDELAY 5, TIMESTAMPANNOS true)
#endif
#ifdef PRIO_QUEUE
  -> FrontDropQueue(100)
#endif
#ifdef BCAST2UNIC
  -> unicfl                                                // transmit to other brn nodes
#endif
  -> fl_piggyback
  -> setsrc::BRN2SetSrcForNeighbor(LINKTABLE $lt, USEANNO true)
  -> BroadcastMultiplexer(NODEIDENTITY $id, USEANNO true)
  -> BRN2EtherEncap(USEANNO true)
  //-> Print("BroadcastMultiplexer out")
  -> [1]output;

  input[3] //passive
  //-> Print("Flooding. Passive overhear",TIMESTAMP true)
  -> [1]routing_peek[1]
  -> BRN2Decap()
  -> [4]fl;

  input[4] //txfeedback success
  //-> Print("FloodFeedback")
  -> BRN2Decap()
  -> [3]fl;

#ifdef BCAST2UNIC
  unicfl[1]                                                // reject transmission
  -> BRN2Decap()
  -> [5]fl;
#endif

  setsrc[1]
  -> BRN2EtherEncap(USEANNO true)
  -> Print("No Src for Dst",100)
  -> Discard;

#ifdef ROUTING_TXFEEDBACK
  Idle -> [2]output;
#endif

}

#endif
