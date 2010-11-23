// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN DSR packets from internal nodes
// input[2] - failed transmission of a BRN DSR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN DSR packets to internal nodes (BRN DSR protocol)

elementclass DSR_IDROUTING {$ID, $LT, $RC |

  dsr_decap :: BRN2DSRDecap(NODEIDENTITY $ID, LINKTABLE $LT);
  dsr_encap :: BRN2DSREncap(NODEIDENTITY $ID, LINKTABLE $LT);

  ridc::BrnRouteIdCache(DEBUG 4);
    
  querier :: BRN2RouteQuerier(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, DSRIDCACHE ridc, DEBUG 0);

  req_forwarder :: BRN2RequestForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, DSRENCAP dsr_encap, ROUTEQUERIER querier, MINMETRIC 9998, ENABLE_DELAY_QUEUE false, DEBUG 0);
  rep_forwarder :: BRN2ReplyForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRDECAP dsr_decap, ROUTEQUERIER querier, DSRENCAP dsr_encap);
  src_forwarder :: BRN2SrcForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, DSRIDCACHE ridc);
  err_forwarder :: BRN2ErrorForwarder(NODEIDENTITY $ID, LINKTABLE $LT, DSRENCAP dsr_encap, DSRDECAP dsr_decap, ROUTEQUERIER querier);

  input[0]
//  -> Print("RouteQuery")
  -> querier[0]
//  -> Print("DSR: querie")
  -> [1]output;                                             // rreq packets (broadcast)
  
  querier[1] 
//  -> Print("DSR: src_forwarder")
  -> [0]src_forwarder;                                      // src routed packets (unicast)

  src_forwarder[0]
//  -> Print("Forward")
  -> [1]output;

  src_forwarder[1]
//  -> Print("Final dest")
  -> [0]output;

  src_forwarder[2]
//  -> Print("Error")
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
  -> Print("Req_fwd_in")
  -> req_forwarder[0]
  -> Print("Req_fwd_out")
  -> [1]output;

  req_forwarder[1]
  -> Print("Target! now send reply")
  -> [0]rep_forwarder
  -> [1]output;

  dsrclf[1] 
  -> Print("Route Reply")
  -> [1]rep_forwarder;

  dsrclf[2]
  -> [1]err_forwarder
  -> [1]output;

  dsrclf[3]
 // -> Print("SRCFWD")
  -> [1]src_forwarder;

  // ------------------
  // undeliverable packets
  // ------------------
  input[2]
  -> [0]err_forwarder;
}
