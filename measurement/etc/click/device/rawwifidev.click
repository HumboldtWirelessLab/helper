#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

elementclass RAWWIFIDEV { DEVNAME $devname, DEVICE $device |

#ifdef CST
#ifdef CST_PROCFILE
  cst::ChannelStats(DEVICE $device, STATS_DURATION 1000, PROCFILE CST_PROCFILE, PROCINTERVAL 1000, RSSI_PER_NEIGHBOUR true, FULL_STATS false, SAVE_DURATION 1000 );
#else
  cst::ChannelStats(DEVICE $device, STATS_DURATION 1000, PROCINTERVAL 1000, RSSI_PER_NEIGHBOUR true, FULL_STATS false, SAVE_DURATION 1000);
#endif
#endif

  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);

  input[0]
#if defined(SIMULATION) || (WIFITYPE == 802)
  -> WifiSeq()                                                      // Set sequencenumber for simulation
#endif
  -> __WIFIENCAP__
#ifdef SETCHANNEL
  -> sc::BRN2SetChannel(DEVICE $device, CHANNEL 0)
#endif

#if WIFITYPE == 805                                                 /***  for ath2 add priority scheduler to prefer operation packet ***/
  -> [1]op_prio_s::PrioSched();                                     /**/
                                                                    /**/
  ath_op::Ath2Operation(DEVICE $device, READCONFIG true, DEBUG 4);  /**/
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
  -> [0]output;


#if WIFITYPE == 805
  dev_decap[1]
  -> rawwifidev_too_small_cnt::Counter
  -> Discard;

  dev_decap[2]
  //-> Print("Post encap operation",TIMESTAMP true)
  -> ath_op;
#endif

}

#endif
