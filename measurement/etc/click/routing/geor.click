// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN GEOR packets from internal nodes
// input[2] - failed transmission of a BRN GEOR packet (broken link) from ds
// input[3] - Passiv (overhear/monitor)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet

// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN GEOR packets to internal nodes (BRN GEOR protocol)
// [2]output - Feedback packets for upper layer

elementclass GEOR {ID $ID, LT $LT, LINKSTAT $LS, DEBUG $debug  |

  gps::GPS();

  gpsmap::GPSMap(TIMEOUT 10000);
  gpslph::GPSLinkprobeHandler(LINKSTAT $LS, GPS gps, GPSMAP gpsmap);

  grt::GeorTable(GPS gps, GPSMAP gpsmap, LINKTABLE $LT, DEBUG 2);
  gqu::GeorQuerier(NODEID $ID, GEORTABLE grt, DEBUG 2);
  gfwd::GeorForwarder(NODEID id, GEORTABLE grt, DEBUG 2);

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
  //-> Print("GOT PACKET")
  -> [0]output;

  gfwd[2]
  -> Discard;

  input[0]
  -> [0]gqu;

  gqu[0]
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

  input[2] -> Discard;
  input[3] -> Discard;
  input[4] -> Discard;

#ifdef ROUTING_TXFEEDBACK
  Idle -> [2]output;
#endif

}
