// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN GEOR packets from internal nodes
// input[2] - failed transmission of a BRN GEOR packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN GEOR packets to internal nodes (BRN GEOR protocol)

elementclass GEOR {ID $ID, LT $LT, LINKSTAT $LS, DEBUG $debug  |

  gps::GPS();
  grt::GeorTable(GPS gps, LINKTABLE $LT, DEBUG $debug);
  glp::GeorLinkProbeHandler(LINKSTAT $LS, GEORTABLE grt);
  gqu::GeorQuerier(NODEID $ID, GEORTABLE grt, DEBUG $debug);
  gfwd::GeorForwarder(NODEID id, GEORTABLE grt, DEBUG $debug);

  Idle
  -> [1]gqu;
  
  gqu[1]
  -> Discard;

  input[1]
  -> BRN2Decap()
  -> gfwd;

  gfwd[0]
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;
  
  gfwd[1]
  -> BRN2EtherEncap(USEANNO true)
//  -> Print("GOT PACKET")
  -> [0]output;
  
  gfwd[2]
  -> Discard;

   input[0]
  -> [0]gqu;
  
  gqu[0]
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

  input[2]
  -> Discard;

 input[3]
 -> Discard;
}
