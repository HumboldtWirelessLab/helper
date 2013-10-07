#include "rawwifidev.click"

//output:
//  0: To me and BRN
//  1: Broadcast and BRN
//  2: Foreign and BRN
//  3: Feedback BRN
//
//input::
//  0: brn
//  1: client
//  2: high priority stuff ( higher than linkprobes)

#ifdef SIMULATION
#define DEFAULT_LINKPROBE_PERIOD            2000
#define DEFAULT_LINKPROBE_TAU              30000
#define DEFAULT_LINKPROBE_PROBES         "2 500"
#else
#define DEFAULT_LINKPROBE_PERIOD            1000
#define DEFAULT_LINKPROBE_TAU             100000
#define DEFAULT_LINKPROBE_PROBES  "2 100 2 1000"
//#define DEFAULT_LINKPROBE_PROBES         "2 500 HT20 15 500 HT20 0 500 4 300 HT40 7 500"
#endif

#ifndef DEFAULT_DATARATE
#define DEFAULT_DATARATE 2
#endif

#ifndef DEFAULT_DATATRIES
#define DEFAULT_DATATRIES 11
#endif

elementclass WIFIDEV { DEVNAME $devname, DEVICE $device, ETHERADDRESS $etheraddress, LT $lt |
	
	availablerates::BrnAvailableRates(DEFAULT 2 4 11 22 12 18 24 36 48 72 96 108); //rates, that are used by that node
	etx_metric :: BRN2ETXMetric($lt);
	//ett_metric :: BRNETTMetric($lt);

	link_stat :: BRN2LinkStat(DEVICE              $device,
#ifdef LINKPROBE_PERIOD
                            PERIOD           LINKPROBE_PERIOD,
#else
                            PERIOD   DEFAULT_LINKPROBE_PERIOD,
#endif
#ifdef LINKPROBE_TAU
                            TAU                 LINKPROBE_TAU,
#else
                            TAU         DEFAULT_LINKPROBE_TAU,
#endif
#ifdef LINKPROBE_PROBES
                            PROBES           LINKPROBE_PROBES,
#else
                            PROBES   DEFAULT_LINKPROBE_PROBES,
#endif
                            RT      availablerates,
//                          METRIC     "etx_metric ett_metric",
                            METRIC     "etx_metric",
                            DEBUG            0 );

  dts::DistTimeSync(LINKSTAT link_stat, TIMEDRIFT -1, OFFSET -1, DEBUG 2);

  brnToMe::BRN2ToThisNode(NODEIDENTITY id);
  wifidevice::RAWWIFIDEV(DEVNAME $devname, DEVICE $device);

  input[0]
#if WIFITYPE == 805
  -> data_power::BrnSetTXPower(DEVICE $device, POWER 61)
#else
  -> data_power::BrnSetTXPower(DEVICE $device, POWER 16)
#endif
  -> data_rate::SetTXRates(RATE0 DEFAULT_DATARATE, TRIES0 DEFAULT_DATATRIES, TRIES1 0, TRIES2 0, TRIES3 0)
  -> brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
//  -> SetTimestamp()
//  -> Print("NODENAME: In Queue", 100, TIMESTAMP true)
  -> data_queue::NotifierQueue(100)
//  -> SetTimestamp()
//  -> Print("NODENAME: Out Queue", 100, TIMESTAMP true)
  -> data_suppressor::Suppressor()
  -> [1]lp_data_scheduler::PrioSched()
#ifdef PRIO_QUEUE
  -> [2]x_prio_q::PrioSched()
#endif
//  -> SetTimestamp()
//  -> Print("NODENAME: To Wifidev", 100, TIMESTAMP true)
  -> wifidevice                                            //rawWifiDevice
//-> PrintWifi("Fromdev", TIMESTAMP true)
  -> filter_tx :: FilterTX()
#if WIFITYPE == 805
  -> error_clf :: WifiErrorClassifier()
#else
  -> error_clf :: FilterPhyErr()
#endif
#ifndef DISABLE_WIFIDUBFILTER
#ifndef DISBALE_BCASTWIFIDUPS
  -> bcast_clf::Classifier(30/80860c0c,
                           - );

  bcast_clf[1]
#endif
  -> WifiDupeFilter()
#ifndef DISBALE_BCASTWIFIDUPS
  -> bcast_dup::Null();

  bcast_clf[0]
  -> bcast_dup
#endif
#endif
  -> wififrame_clf :: Classifier( 1/40%40,  // wep frames
                                  0/00%0f,  // management frames
                                      - );

  filter_tx[1]
#ifdef WIFIDEV_LINKSTAT_DEBUG
  -> PrintWifi("NODENAME:NODEDEVICE ", TIMESTAMP true)
#endif
 // -> Print("RXERR")
#ifdef PRIO_QUEUE
  -> WifiDecap()
  -> ig_feedback_clf :: Classifier( 12/8888, - );

  ig_feedback_clf[1]
#else
#ifdef BRNFEEDBACK
  -> WifiDecap()
#endif
#endif
#ifdef BRNFEEDBACK
  -> txfb_brn_clf :: Classifier( 12/BRN_ETHERTYPE, - )
  -> brnfb_lsclf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
  -> Discard;

  brnfb_lsclf[1]
  -> [3]output;

  txfb_brn_clf[1]
#endif
  -> Discard;

  wififrame_clf[0]
    -> Discard;

  wififrame_clf[1]
    -> Discard;

  wififrame_clf[2]
//  -> BRN2PrintWifi("RX")
    -> dts
    -> WifiDecap()
//  -> Print("Data")
    -> brn_ether_clf :: Classifier( 12/BRN_ETHERTYPE, - )
    -> lp_clf :: Classifier( 14/BRN_PORT_LINK_PROBE, - )
    -> BRN2EtherDecap()
//  -> Print("Linkprobe",320)
    -> link_stat
//  -> Print("Linkprobe_out",320)
    -> lp_etherencap::EtherEncap(BRN_ETHERTYPE_HEX, deviceaddress, ff:ff:ff:ff:ff:ff)
#ifndef DISABLE_LP_POWER
#if WIFITYPE == 805
    -> lp_power::BrnSetTXPower(DEVICE $device, POWER 61)
#else
    -> lp_power::BrnSetTXPower(DEVICE $device, POWER 16)
#endif
#endif
    -> lp_wifiencap::WifiEncap(0x00, 0:0:0:0:0:0)
    -> lp_queue::FrontDropQueue(2)
    -> lp_suppressor::Suppressor()
    -> [0]lp_data_scheduler;

  brn_ether_clf[1]                         //no brn no interference stuff
  //-> Print()  
  -> Discard;

  lp_clf[1]                               //brn, but no lp
#ifdef CST
#ifdef SIMULATION
#ifdef COOPCST
  -> co_cst_clf :: Classifier( 14/BRN_PORT_CHANNELSTATSINFO, - );

  co_cst_clf[1]
#endif
#endif
#endif
  //-> Print("Data, no LP")
  -> [1]data_suppressor[1]
  -> brnToMe;

#ifdef CST
#ifdef SIMULATION
#ifdef COOPCST
  co_cst_clf[0]
  //-> Print("ChannelStats")
  -> BRN2EtherDecap()
  -> BRN2Decap()
  -> cocst::CooperativeChannelStats(CHANNELSTATS wifidevice/cst, NEIGHBOURS true, INTERVAL 1000, DEBUG 2)
  -> cocst_etherencap::EtherEncap(BRN_ETHERTYPE_HEX, deviceaddress, ff:ff:ff:ff:ff:ff)
  -> cocst_rate::SetTXRate(RATE 2, TRIES 1)
  -> brnwifi;
#endif
#endif
#endif

  brnToMe[0] -> /*Print("NODENAME: wifi0", TIMESTAMP true) ->*/ [0]output;
  brnToMe[1] -> /*Print("wifi1") ->*/ [1]output;
  brnToMe[2] -> /*Print("wifi2") ->*/ [2]output;

  input[1] -> Discard;

#ifdef PRIO_QUEUE

  input[2]
  //-> x_data_rate::SetTXRates(RATE0 DEFAULT_DATARATE, TRIES0 DEFAULT_DATATRIES, TRIES1 0, TRIES2 0, TRIES3 0)
  //-> x_brnwifi::WifiEncap(0x00, 0:0:0:0:0:0)
  -> [1]x_prio_q;

  Idle()
  -> ig_flow::BRN2SimpleFlow(EXTRADATA "Interferenzgraph", ELEMENTID 255, DEBUG 2);

  ig_feedback_clf[0]
  -> BRN2EtherDecap()
  -> Classifier( 0/BRN_PORT_FLOW )
  -> BRN2Decap()
  -> [1]ig_flow
  -> Print("packet")
  -> EtherEncap(0x8888, $etheraddress, ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> ig_rate :: SetTXRate(2)
#if WIFITYPE == 805
  -> ig_power :: BrnSetTXPower(DEVICE $device, POWER 61)
#else
  -> ig_power :: BrnSetTXPower(DEVICE $device, POWER 16)
#endif
  -> SetTimestamp()
  -> ig_notifierqueue::NotifierQueue(500)
  -> ig_suppressor::Suppressor()
  //-> SetTimestamp()
  //-> Print(TIMESTAMP true)
  -> [0]x_prio_q;

#endif

  error_clf[1]
#ifdef SIMULATION
  -> PrintCRCError(LABEL "CRC", RATE 2)
#endif
//  -> Print("RXPHYERR")
  -> Discard;

  link_stat[1]
  -> Print("Linkstat error",200)
  -> Discard;
//  -> BRN2EtherEncap()
//  -> WifiEncap(0x00, 0:0:0:0:0:0)
//  -> RadiotapEncap()
//  -> ToDump("RESULTDIR/linkstat_error.NODENAME.NODEDEVICE.dump");

}
