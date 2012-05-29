// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN DSR packets from internal nodes
// input[2] - failed transmission of a BRN DSR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN DSR packets to internal nodes (BRN DSR protocol)


#ifndef DSR_PARAM_LAST_HOP_OPT
#define DSR_PARAM_LAST_HOP_OPT true
#endif

#ifndef DSR_PARAM_PASSIVE_ACK_RETRIES
#define DSR_PARAM_PASSIVE_ACK_RETRIES 2
#endif

#ifndef DSR_PARAM_PASSIVE_ACK_INTERVAL
#define DSR_PARAM_PASSIVE_ACK_INTERVAL 0
#endif

#ifndef DSR_PARAM_FORCE_PASSIVE_ACK_RETRIES
#define DSR_PARAM_FORCE_PASSIVE_ACK_RETRIES false
#endif





elementclass DSR {$ID, $LT, $METRIC, $ROUTEMAINT |

  dsr_decap :: BRN2DSRDecap();
  dsr_encap :: BRN2DSREncap(NODEIDENTITY $ID, LINKTABLE $LT);

  dsr_stats :: DSRStats(DEBUG 2);

#ifdef DSR_ID_CACHE
  ridc::BrnRouteIdCache(DEBUG 4);
#endif

#ifdef DSR_ID_CACHE
  querier :: BRN2RouteQuerier(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, METRIC $METRIC, DSRIDCACHE ridc, ROUTEMAINTENANCE $ROUTEMAINT, DEBUG 2);
#else
  querier :: BRN2RouteQuerier(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, METRIC $METRIC, ROUTEMAINTENANCE $ROUTEMAINT, DEBUG 2);
#endif

  req_forwarder :: BRN2RequestForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, DSRENCAP dsr_encap, ROUTEQUERIER querier, MINMETRIC 5000, ENABLE_DELAY_QUEUE true, DEBUG 2,
                                        LAST_HOP_OPT DSR_PARAM_LAST_HOP_OPT, PASSIVE_ACK_RETRIES DSR_PARAM_PASSIVE_ACK_RETRIES, PASSIVE_ACK_INTERVAL DSR_PARAM_PASSIVE_ACK_INTERVAL, FORCE_PASSIVE_ACK_RETRIES DSR_PARAM_FORCE_PASSIVE_ACK_RETRIES);
  rep_forwarder :: BRN2ReplyForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, ROUTEQUERIER querier, DSRENCAP dsr_encap);

#ifdef DSR_ID_CACHE
  src_forwarder :: BRN2SrcForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, ROUTEQUERIER querier, DSRDECAP dsr_decap, DSRIDCACHE ridc, DEBUG 2);
#else
  src_forwarder :: BRN2SrcForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, ROUTEQUERIER querier, DSRDECAP dsr_decap, DEBUG 2);
#endif

  err_forwarder :: BRN2ErrorForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, ROUTEQUERIER querier, DEBUG 2);
  routing_peek :: DSRPeek(DEBUG 2);

  input[0]
#ifdef DEBUG_DSR
  -> Print("NODENAME: RouteQuery")
#endif
  -> querier[0]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: DSR: querry", 100, TIMESTAMP true)
#endif
 -> BRN2EtherEncap() 
 -> [1]output;                                             // rreq packets (broadcast)
  
  querier[1] 
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: DSR: src_forwarder", 100, TIMESTAMP true)
#endif
  -> [0]src_forwarder;                                      // src routed packets (unicast)

  src_forwarder[0]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Forward", 100, TIMESTAMP true)
#endif
  -> dsr_stats
  -> routing_peek
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

  src_forwarder[1]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Final dest", 100, TIMESTAMP true)
#endif
  -> [0]output;

  src_forwarder[2]
#ifdef DEBUG_DSR
  -> Print("NODENAME: src_fwd Error")
#endif
  -> tee_to_err_fwd :: Tee()
  -> Discard;                                                  //is for BRNiapp

  tee_to_err_fwd[1]
  -> [0]err_forwarder;

  // ------------------
  // internal packets
  // ------------------
  input[1]
  -> dsrclf :: Classifier( 6/01, //DSR_RREQ
                           6/02, //DSR_RREP
                           6/03, //DSR_RERR
                           6/04, //DSR_SRC
                         );

  dsrclf[0]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Req_fwd_in", 100, TIMESTAMP true)
#endif
  -> req_forwarder[0]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Req_fwd_out", 100, TIMESTAMP true)
#endif
  -> BRN2EtherEncap()
  -> [1]output;

  req_forwarder[1]
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Target! now send reply", 100, TIMESTAMP true)
#endif
  -> [0]rep_forwarder
  -> BRN2EtherEncap()
  -> [1]output;

  dsrclf[1] 
#ifdef DEBUG_DSR
  -> SetTimestamp()
  -> Print("NODENAME: Route Reply")
#endif
  -> [1]rep_forwarder;

  dsrclf[2]
  -> [1]err_forwarder
  -> BRN2EtherEncap()
  -> [1]output;

  dsrclf[3]
#ifdef DEBUG_DSR
  -> Print("NODENAME: SRCFWD")
#endif
  -> [1]src_forwarder;

  // ------------------
  // undeliverable packets
  // ------------------
  input[2]
  //-> Discard;
  -> [0]err_forwarder;

  input[3] -> Discard;
}

