elementclass DHT_OMNI { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |
  dhtrouting :: DHTRoutingOmni(ETHERADDRESS $etheraddress, LINKSTAT $lt, UPDATEINT $updateint, DEBUG $debug)
  
  input[0] /*-> Print("R-in",100) */-> dhtrouting /*-> Print("R-out",100)*/ -> [0]output;
  dhtrouting[1] -> [1]output;
  
}

