#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

elementclass RAWWIFIDEV { DEVNAME $devname, DEVICE $device |

#ifdef CST
#ifdef CST_PROCFILE
  cst::ChannelStats(STATS_DURATION 1000, SAVE_DURATION 1000, PROCFILE CST_PROCFILE, PROCINTERVAL 1000, RSSI_PER_NEIGHBOUR true, STATS_TIMER true, SMALL_STATS true);
#else
  cst::ChannelStats(STATS_DURATION 1000, SAVE_DURATION 1000, RSSI_PER_NEIGHBOUR true, STATS_TIMER true);
#endif
#endif

  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);

  input[0]
#ifdef SIMULATION
  -> WifiSeq()
#endif
  -> __WIFIENCAP__

#if WIFITYPE == 805
  -> [1]op_prio_q::PrioSched();

  ath_op::Ath2Operation();

  ath_op[1] -> Discard;

  Idle
  -> ath_op
  -> ath_op_q::NotifierQueue(10)
  -> op_prio_q
#endif

  -> rawdev;

  rawdev
  -> __WIFIDECAP__
#ifdef CST
  -> cst
#endif
  -> [0]output;

#ifdef SETCHANNEL
  Idle
  -> sc::BRN2SetChannel(CHANNEL 0)
  -> Discard;
#endif

}

#endif
