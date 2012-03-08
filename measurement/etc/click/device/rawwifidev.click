#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

/*
 * Input:
 * 0: ??
 *
 * Output:
 * 0: pkts from raw device
 * 1: pkts from raw device are decaped and passed ???
 */



elementclass RAWWIFIDEV { DEVNAME $devname, DEVICE $device |

#ifndef CST_PROCINTERVAL
#define CST_PROCINTERVAL 1000
#endif

#ifndef CST_SAVE_DURATION
#define CST_SAVE_DURATION 1000
#endif

#ifndef CST_STATS_DURATION
#define CST_STATS_DURATION 1000
#endif

#ifdef CST

//define CST_PROCFILE for simulation. Path is not really used, but no path means no hw channel stats 
#ifdef SIMULATION
#ifndef CST_PROCFILE
#define CST_PROCFILE /simulation
#endif
#endif

#ifdef CST_PROCFILE
  cst::ChannelStats(DEVICE $device, STATS_DURATION CST_STATS_DURATION, PROCFILE CST_PROCFILE, PROCINTERVAL CST_PROCINTERVAL, NEIGHBOUR_STATS true, FULL_STATS false, SAVE_DURATION CST_SAVE_DURATION );
#else
  cst::ChannelStats(DEVICE $device, STATS_DURATION CST_STATS_DURATION, PROCINTERVAL CST_PROCINTERVAL, NEIGHBOUR_STATS true, FULL_STATS false, SAVE_DURATION CST_SAVE_DURATION );
#endif
#endif

#ifdef SIMULATION
  cinfo::CollisionInfo();
#ifdef USE_RTS_CTS
  pli::PacketLossInformation();
#ifdef PLE
  ple::PacketLossEstimator(CHANNELSTATS cst, COLLISIONINFO cinfo, HIDDENNODE hnd, PLI pli, DEVICE $device, DEBUG 2);
#endif
#endif
#endif


  // RAWDEV from include rawdev.click
  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);

  input[0]
#if defined(SIMULATION) || (WIFITYPE == 802)
  -> WifiSeq()                                                      // Set sequencenumber for simulation
#endif
#ifndef DISABLE_TOS2QUEUEMAPPER
#ifdef SIMULATION
#ifdef CST
#ifdef USE_RTS_CTS
  -> tosq::Tos2QueueMapper( CWMIN CWMINPARAM, CWMAX CWMAXPARAM, AIFS AIFSPARAM, CHANNELSTATS cst, COLLISIONINFO cinfo, PLI pli, DEBUG 2)
#else
  -> tosq::Tos2QueueMapper( CWMIN CWMINPARAM, CWMAX CWMAXPARAM, AIFS AIFSPARAM, CHANNELSTATS cst, COLLISIONINFO cinfo, DEBUG 2)
#endif //PLE
#else //CST
  -> tosq::Tos2QueueMapper( CWMIN CWMINPARAM, CWMAX CWMAXPARAM, AIFS AIFSPARAM )
#endif //CST
#endif //SIMULATION
//#else
// -> Tos2QueueMapper()
//#endif
#endif
#ifdef USE_RTS_CTS
  ->setrtscts::Brn2_SetRTSCTS(PLI pli)
#endif
#ifdef SETCHANNEL
  -> sc::BRN2SetChannel(DEVICE $device, CHANNEL 0)
#endif
  -> __WIFIENCAP__

#if WIFITYPE == 805                                                 /***  for ath2 add priority scheduler to prefer operation packet ***/
  -> [1]op_prio_s::PrioSched();                                     /**/
                                                                    /**/
  ath_op::Ath2Operation(DEVICE $device, READCONFIG true, DEBUG 2);  /**/
                                                                    /**/
  ath_op                                                            /**/
  -> ath_op_q::NotifierQueue(10)                                    /**/
  -> op_prio_s                                                      /**/
#endif                                                              /***  end of ath2                                                **/
  -> rawdev;

  rawdev
  -> dev_decap::__WIFIDECAP__
#ifdef CST
  -> cst                                                            //add channel stats if requested
#endif
#ifdef SIMULATION
  -> cinfo
#ifdef PLE
  -> ple
  //-> co_cst
#endif
#endif
#ifdef CERR
  -> hnd::HiddenNodeDetection(DEVICE $device, DEBUG 2)
#endif
  -> [0]output;


#if WIFITYPE == 805
  dev_decap[1]
  -> rawwifidev_too_small_cnt::Counter
  -> Discard;

  dev_decap[2]
  //-> Print("Post encap operation",TIMESTAMP true)
  -> ath_op;
#endif

#ifdef PACKET_REUSE
  rawdev[1]
  -> __WIFIDECAP__
  -> [1]output;
#endif
}

#endif
