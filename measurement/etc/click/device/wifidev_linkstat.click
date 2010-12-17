#include "rawwifidev.click"

//output:
//  0: To me and BRN
//  1: Broadcast and BRN
//  2: Foreign and BRN
//  3: To me and NO BRN
//  4: BROADCAST and NO BRN
//  5: Foreign and NO BRN
//  6: Feedback BRN
//  7: Feedback Other
//
//input::
//  0: brn
//  1: client
//  2: high priority stuff ( higher than linkprobes)


elementclass WIFIDEV { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, LT $lt |

//  nblist::BRN2NBList();  //stores all neighbors (known (friend) and unknown (foreign))
//  nbdetect::NeighborDetect(NBLIST nblist, DEVICE $device);
  rates::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);
  proberates::AvailableRates(DEFAULT 2 12 22 108);
  etx_metric :: BRN2ETXMetric($lt);

  link_stat :: BRN2LinkStat(ETHTYPE          0x0a04,
                            DEVICE          $device,
#ifdef SIMULATION			    
                            PERIOD             2000,
                            TAU               30000,
#else
                            PERIOD             1000,
                            TAU              100000,
#endif
                            ETX          etx_metric,
#ifdef SIMULATION
                            PROBES  "2 300",
#else
//                          PROBES  "2 100 4 100 11 100 12 100 22 100 18 100 24 100 36 100 48 100 72 100 96 100 108 100",
                            PROBES  "2 200 12 200",
#endif
                            RT           proberates);

  brnToMe::BRN2ToThisNode(NODEIDENTITY id);
  wifidevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);

  input[0]
  -> data_power :: SetTXPower(15)
  -> data_rate :: SetTXRate(RATE 2, TRIES 14)
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> data_queue::NotifierQueue(100)
  -> [1]lp_data_scheduler::PrioSched()
#ifdef PRIO_QUEUE
  -> [1]x_prio_q::PrioSched()
#endif
  -> wifidevice
  -> filter_tx :: FilterTX()
#if WIFITYPE == 805
  -> error_clf :: WifiErrorClassifier()
#else
  -> error_clf :: FilterPhyErr()
#endif
  -> WifiDupeFilter()
  -> wififrame_clf :: Classifier( 1/40%40,  // wep frames
                                  0/00%0f,  // management frames
                                      - );

  filter_tx[1]
#ifdef WIFIDEV_LINKSTAT_DEBUG
  -> PrintWifi("NODENAME:NODEDEVICE ", TIMESTAMP true)
#endif
  -> Discard;

  wififrame_clf[0]
    -> Discard;

  wififrame_clf[1]
    -> Discard;

  wififrame_clf[2]
    -> WifiDecap()
//    -> nbdetect
    //-> Print("Data")
    -> brn_ether_clf :: Classifier( 12/8086, - )
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
    -> BRN2EtherDecap()
    -> link_stat
    -> EtherEncap(0x8086, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> power::SetTXPower(19)
    -> lp_wifiencap::WifiEncap(0x00, 0:0:0:0:0:0)
    -> lp_queue::NotifierQueue(10)
    -> [0]lp_data_scheduler;

  brn_ether_clf[1]                         //no brn
// -> Print()
   -> Discard;

  lp_clf[1]                               //brn, but no lp
//-> Print("Data, no LP")
  -> brnToMe;

  brnToMe[0] -> /*Print("NODENAME: wifi0", TIMESTAMP true) ->*/ [0]output;
  brnToMe[1] -> /*Print("wifi1") ->*/ [1]output;
  brnToMe[2] -> /*Print("wifi2") ->*/ [2]output;

  input[1] -> Discard;

#ifdef PRIO_QUEUE
  input[2]
  -> x_brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> [0]x_prio_q;
#endif
}
