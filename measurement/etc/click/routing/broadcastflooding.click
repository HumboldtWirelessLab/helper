//input[0]: From Src (who wants to send a broadcats)
//input[1]: Received from brn node
//input[2]: Errors (not used)
//[0]output: Local copy (broadcast)
//[1]output: To other brn nodes

elementclass BROADCASTFLOODING {$ID, $ADDRESS, $LST |

  flp::SimpleFlooding();
//flp::ProbabilityFlooding(LINKSTAT $LST);
  sfl::Flooding(FLOODINGPOLICY flp, ETHERADDRESS $ADDRESS);
  
  input[0]
  -> [0]sfl;
  
  input[1]
  -> BRN2Decap()
  -> [1]sfl;
  
  input[2]
  -> Discard;
  
  sfl[0]
  -> [0]output;

  sfl[1] 
  -> BRN2EtherEncap(USEANNO true) 
//-> Print("SimpleFlood-Ether-OUT")
  -> [1]output;
  
}
