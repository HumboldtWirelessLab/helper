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
  -> data_power::SetTXPower(15)
  -> data_rate::SetTXRate(RATE 2, TRIES 11)
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> data_queue::NotifierQueue(100)
  -> data_suppressor::Suppressor()
  -> [1]lp_data_scheduler::PrioSched()
#ifdef PRIO_QUEUE
  -> [2]x_prio_q::PrioSched()
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
    //-> Print("Data")
    -> brn_ether_clf :: Classifier( 12/BRN_ETHERTYPE, - )
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
    -> BRN2EtherDecap()
    -> link_stat
    -> lp_etherencap::EtherEncap(BRN_ETHERTYPE_HEX, deviceaddress, ff:ff:ff:ff:ff:ff)
    -> lp_power::SetTXPower(19)
    -> lp_wifiencap::WifiEncap(0x00, 0:0:0:0:0:0)
    -> lp_queue::FrontDropQueue(2)
    -> lp_suppressor::Suppressor()
    -> [0]lp_data_scheduler;

  brn_ether_clf[1]                         //no brn
   // -> Print()
   -> Discard;

  lp_clf[1]                               //brn, but no lp
  //-> Print("Data, no LP")
  -> [1]data_suppressor[1]
  -> brnToMe;

  brnToMe[0] -> /*Print("NODENAME: wifi0", TIMESTAMP true) ->*/ [0]output;
  brnToMe[1] -> /*Print("wifi1") ->*/ [1]output;
  brnToMe[2] -> /*Print("wifi2") ->*/ [2]output;

  input[1] -> Discard;

#ifdef PRIO_QUEUE

  input[2]
  -> x_brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> [1]x_prio_q;

  qc_q::NotifierQueue(500);
  qc_suppressor::Suppressor();

  qc::BRN2PacketQueueControl(QUEUESIZEHANDLER qc_q.length, QUEUERESETHANDLER qc_q.reset, SUPPRESSORHANDLER qc_suppressor.active0, MINP 200 , MAXP 500, DISABLE_QUEUE_RESET false, DEBUG 2)
  -> EtherEncap(0x8888, $etheraddress , ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> SetTimestamp()
  -> qc_q
  -> qc_suppressor
//  -> SetTimestamp()
//  -> Print(TIMESTAMP true)
  -> [0]x_prio_q;

/*
  qc_q[1]
  -> SetTimestamp()
  -> Print(TIMESTAMP true)
  -> Discard;
*/

#endif

}
