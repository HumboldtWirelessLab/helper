// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN BATMAN packets from internal nodes
// input[2] - failed transmission of a BRN BATMAN packet (broken link) from ds
// input[3] - Passiv (overhear/monitor)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN BATMAN packets to internal nodes (BRN BATMAN protocol)
// [2]output - Feedback packets for upper layer

elementclass BATMAN {$ID, $LT |

  brt::BatmanRoutingTable( NODEID $ID, LINKTABLE $LT, ORIGINATORMODE 1);

  bos::BatmanOriginatorSource( BATMANTABLE brt, NODEID $ID, INTERVAL 2000);
  bofwd::BatmanOriginatorForwarder( NODEID $ID, BATMANTABLE brt, DEBUG 2)

  bf::BatmanForwarder( NODEID $ID, BATMANTABLE brt);
  br::BatmanRouting(NODEID $ID, BATMANTABLE brt);

  bfd::BatmanFailureDetection( NODEID $ID, BATMANTABLE brt, ACTIVE true);

  input[1]
  -> BRN2Decap()
  -> Print("NODENAME: BATMAN", TIMESTAMP true)
  -> bc::Classifier( 0/10,  //originator
                     0/20   //routingfwd
                  );

  bc[0]
  -> Print("Forward org")
  -> bofwd
  -> brnee::Null()
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

  bos
  -> brnee;

  bc[1]
//-> Print("NODENAME: Routing FWD", TIMESTAMP true)
  -> bfd
  -> bf;

  bf[0]
  -> [0]output;

  bf[1]
//-> Print("Fwd to next hop", TIMESTAMP true) 
  -> brnee;

  bf[2]
  -> Print("RouteError",150)
  -> Discard;

  bfd[1]
  -> Print("RouteFailure")
  -> Discard;

  input[0]
  -> br;

  br[0]
//-> Print("Its me")
  -> [0]output;

  br[1]
//-> Print("NODEDEVICE: On Route", TIMESTAMP true)
  -> brnee;

  br[2]
//-> Print("Unknown Dest")
  -> Discard;

  input[2]
  -> [1]bfd[2]
//-> Print("Retry")
  -> brnee;

  input[3] -> Discard;
  input[4] -> Discard;

#ifdef ROUTING_TXFEEDBACK
  Idle -> [2]output;
#endif

}
