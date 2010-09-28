elementclass DHT_KLIBS { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |
  dhtrouting :: DHTRoutingKlibs(ETHERADDRESS $etheraddress, LINKSTAT $lt, UPDATEINT $updateint)
  
  input[0] /*-> Print("R-in",100) */-> dhtrouting /*-> Print("R-out",100)*/ -> [0]output;
  dhtrouting[1] -> [1]output;
  
}

