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




#ifdef CST

#ifndef CST_PROCINTERVAL
#define CST_PROCINTERVAL 1000
#endif

#ifndef CST_SAVE_DURATION
#define CST_SAVE_DURATION 1000
#endif

#ifndef CST_STATS_DURATION
#define CST_STATS_DURATION 1000
#endif

//define CST_PROCFILE for simulation. Path is not really used, but no path means no hw channel stats
#ifndef CST_PROCFILE

#ifdef SIMULATION
#define CST_PROCFILE /simulation
#else

#if WIFITYPE == 803

#if DEVICENUMBER == 0
#define CST_PROCFILE "/sys/devices/pci0000\:00/0000\:00\:11.0/stats/channel_utility"
#else
#define CST_PROCFILE "/sys/devices/pci0000\:00/0000\:00\:12.0/stats/channel_utility"
#endif

#else

#define CST_PROCFILE "/proc/net/madwifi/NODEDEVICE/channel_utility"

#endif
#endif
#endif
#endif

elementclass RAWWIFIDEV { DEVNAME $devname, DEVICE $device |

#ifdef CST
#ifdef CST_PROCFILE
  CST::ChannelStats(DEVICE $device, STATS_DURATION CST_STATS_DURATION, PROCFILE CST_PROCFILE, PROCINTERVAL CST_PROCINTERVAL, NEIGHBOUR_STATS true, FULL_STATS false, SAVE_DURATION CST_SAVE_DURATION );
#else
  CST::ChannelStats(DEVICE $device, STATS_DURATION CST_STATS_DURATION, PROCINTERVAL CST_PROCINTERVAL, NEIGHBOUR_STATS true, FULL_STATS false, SAVE_DURATION CST_SAVE_DURATION );
#endif
#endif

#ifdef SIMULATION
#ifdef PLE
#define COLLINFO
#define CERR
#endif

#ifdef COLLINFO
  cinfo::CollisionInfo();
#endif

#ifdef CERR
#ifdef COOPCST_STRING
  hnd::HiddenNodeDetection(DEVICE $device, TIMEOUT 1000, COOPCHANNELSTATSPATH COOPCST_STRING, DEBUG 2);
#else
  hnd::HiddenNodeDetection(DEVICE $device, TIMEOUT 1000, DEBUG 2);
#endif
#endif

#ifdef PLE
  pli::PacketLossInformation();
#ifdef COOPCST
  ple::PacketLossEstimator(CHANNELSTATS cst, COLLISIONINFO cinfo, HIDDENNODE hnd, PLI pli, COOPCHANNELSTATS cocst, DEVICE $device, HNWORST false, DEBUG 4);
#else
  ple::PacketLossEstimator(CHANNELSTATS cst, COLLISIONINFO cinfo, HIDDENNODE hnd, PLI pli, DEVICE $device, HNWORST false, DEBUG 2);
#endif
#endif
#endif



  // RAWDEV from include rawdev.click
  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);

#ifdef SIMULATION
#ifdef CST
  bo_maxtp::BoMaxThroughput(CHANNELSTATS CST, DEBUG 2);

  bo_cla::BoChannelLoadAware(CHANNELSTATS CST, TARGETLOAD 90, TARGETDIFF 0, CAP 1, CST_SYNC 1, DEBUG 2);

  bo_targetpl::BoTargetPacketloss(CHANNELSTATS CST, TARGETPL 10, DEBUG 2);

  bo_nbs::BoNeighbours(CHANNELSTATS CST, DEBUG 2);

  bo_learning::BoLearning(MIN_CWMIN 32, MAX_CWMIN 1024, STRICT 1, CAP 1, DEBUG 2);

  bo_const::BoConstant(BO 32, DEBUG 2);

  bo_minstrel::BoMinstrel(DEBUG 4);
#endif
#endif

#ifdef USE_RTS_CTS
#ifdef PLE
  rtscts_ple::RtsCtsPLI(PLI pli);
#endif
  rtscts_packetsize::RtsCtsPacketSize(PACKETSIZE 1032);
  rtscts_random::RtsCtsRandom(PROBABILITY 50);
#ifdef CERR
  rtscts_hiddennode::RtsCtsHiddenNode(HIDDENNODE hnd);
#define RTSCTS_HN
#endif
#endif


  input[0]
#if defined(SIMULATION) || (WIFITYPE == 803)
  -> WifiSeq()                                                      // Set sequencenumber for simulation
#endif
#ifndef DISABLE_TOS2QUEUEMAPPER

#ifndef TOS2QUEUEMAPPER_STRATEGY
#define TOS2QUEUEMAPPER_STRATEGY 0
#endif

#ifndef TOS2QUEUEMAPPER_QUEUEMAPPING
#define TOS2QUEUEMAPPER_QUEUEMAPPING 0
#endif

#ifndef TOS2QUEUEMAPPER_MAC_BO_SCHEME
#define TOS2QUEUEMAPPER_MAC_BO_SCHEME 0
#endif

#ifndef TOS2QUEUEMAPPER_QUEUEMODE
#define TOS2QUEUEMAPPER_QUEUEMODE 0
#endif

#ifndef TOS2QUEUEMAPPER_QUEUEVAL
#define TOS2QUEUEMAPPER_QUEUEVAL 1
#endif

#ifndef TOS2QUEUEMAPPER_CWMINMAXMODE
#define TOS2QUEUEMAPPER_CWMINMAXMODE 0
#endif

#ifndef TOS2QUEUEMAPPER_CWMINMAXVAL
#define TOS2QUEUEMAPPER_CWMINMAXVAL 7
#endif

#ifdef SIMULATION
#ifdef CST
  -> tosq::Tos2QueueMapper( DEVICE $device, STRATEGY TOS2QUEUEMAPPER_STRATEGY, BO_SCHEMES "bo_maxtp bo_cla bo_targetpl bo_learning bo_nbs bo_const bo_minstrel",
                            MAC_BO_SCHEME TOS2QUEUEMAPPER_MAC_BO_SCHEME,                                        /*   0 - Default (Exp)   1- Exp   2 - Fib   */
                            QUEUEMODE TOS2QUEUEMAPPER_QUEUEMODE, QUEUEVAL TOS2QUEUEMAPPER_QUEUEVAL,             /*   Mode: 0-Exp 1-Mul 2-Add 3-Fib    */
                            CWMINMAXMODE TOS2QUEUEMAPPER_CWMINMAXMODE, CWMINMAXVAL TOS2QUEUEMAPPER_CWMINMAXVAL, /*   cwminmaxval -> retries; Mode: 0-Exp 1-Mul 2-Add 3-Fib    */
                            QUEUEMAPPING TOS2QUEUEMAPPER_QUEUEMAPPING, DEBUG 4)
#endif
#endif //SIMULATION
#endif

#ifdef USE_RTS_CTS
#ifdef PLE

#ifndef RTS_CTS_STRATEGY
#define RTS_CTS_STRATEGY 1
#endif

#ifdef RTSCTS_HN
  -> setrtscts::Brn2_SetRTSCTS(STRATEGY RTS_CTS_STRATEGY, RTSCTS_SCHEMES "rtscts_ple rtscts_packetsize rtscts_random rtscts_hiddennode")
#else
  -> setrtscts::Brn2_SetRTSCTS(STRATEGY RTS_CTS_STRATEGY, RTSCTS_SCHEMES "rtscts_ple rtscts_packetsize rtscts_random")
#endif

#else

#ifdef CERR
  -> setrtscts::Brn2_SetRTSCTS(STRATEGY RTS_CTS_STRATEGY, RTSCTS_SCHEMES "rtscts_packetsize rtscts_random rtscts_hiddennode")
#else
  -> setrtscts::Brn2_SetRTSCTS(STRATEGY RTS_CTS_STRATEGY, RTSCTS_SCHEMES "rtscts_packetsize rtscts_random")
#endif

#endif
#endif

  //-> Print("Wifi", TIMESTAMP true)

#ifdef SETCHANNEL
  -> sc::BRN2SetChannel(DEVICE $device, CHANNEL 0)
#endif
  -> __WIFIENCAP__

#ifndef NOATHOPERATION

#if WIFITYPE == 805                                                 /***  for ath2 add priority scheduler to prefer operation packet ***/
  -> [1]op_prio_s::PrioSched();                                     /**/
                                                                    /**/
  ath_op::Ath2Operation(DEVICE $device, READCONFIG true, DEBUG 2);  /**/
                                                                    /**/
  ath_op                                                            /**/
  -> ath_op_q::NotifierQueue(10)                                    /**/
  -> op_prio_s                                                      /**/
#endif                                                              /***  end of ath2                                                **/
#endif
  -> rawdev;

  rawdev
  -> dev_decap::__WIFIDECAP__
#ifdef CST
  -> CST                                                            //add channel stats if requested
#endif
#ifdef SIMULATION
#ifdef COLLINFO
  -> cinfo
#endif
#ifdef PLE
  -> ple
#endif
#endif
#ifdef CERR
  //-> BRN2PrintWifi()
  -> hnd
#endif
#ifdef SIMULATION
#ifdef CST
  -> Tos2QueueMapperTXFeedback(TOS2QM tosq, DEBUG 2)
#endif
#endif
#ifdef FOREIGNRXSTATS
  -> ForeignRxStats(DEVICE $device,TIMEOUT 15, DEBUG 2)
#endif
  -> [0]output;


#ifndef NOATHOPERATION
#if WIFITYPE == 805
  dev_decap[1]
  -> rawwifidev_too_small_cnt::Counter
  -> Discard;

  dev_decap[2]
  //-> Print("Post encap operation",TIMESTAMP true)
  -> ath_op;
#endif
#endif

#ifdef PACKET_REUSE
  rawdev[1]
  -> __WIFIDECAP__
  -> [1]output;
#endif
}

#endif
