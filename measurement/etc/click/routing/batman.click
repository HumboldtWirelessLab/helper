// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN BATMAN packets from internal nodes
// input[2] - failed transmission of a BRN BATMAN packet (broken link) from ds
// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN BATMAN packets to internal nodes (BRN BATMAN protocol)

elementclass BATMAN {$ID, $LT |

  brt::BatmanRoutingTable( NODEID $ID);

  bos::BatmanOriginatorSource( NODEID $ID, INTERVAL 2000);
  bofwd::BatmanOriginatorForwarder( NODEID $ID, BATMANTABLE brt)

  bf::BatmanForwarder( NODEID $ID, BATMANTABLE brt);
  br::BatmanRouting(NODEID $ID, BATMANTABLE brt);
  
  input[1]
  -> BRN2Decap()
//-> Print("BATMAN")
  -> bc::Classifier( 0/01,  //originator
                     0/02   //routingfwd
                  );

  bc[0]
//-> Print("Forward org")
  -> bofwd
  -> brnee::Null()
  -> [1]output;

  bos
  -> brnee;

  bc[1]
  //-> Print("Routing FWD")
  -> bf;

  bf[0]
  -> [0]output;

  bf[1] 
//-> Print("Fwd to next hop") 
  -> brnee;
  
  bf[2] 
//-> Print("RouteError")
  -> Discard;

  input[0]
  -> br;

  br[0]
//-> Print("Its me")
  -> [0]output;

  br[1] 
//-> Print("On Route")
  -> brnee;
  
  br[2]
//-> Print("Unknown Dest")
  -> Discard;

  input[2]
  -> Discard;
  
}
