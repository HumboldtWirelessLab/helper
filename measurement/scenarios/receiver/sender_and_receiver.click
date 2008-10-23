BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> AthdescDecap()
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

  ftx[1]
  -> Print("TXFeedback")
  -> Discard;

BRN2PacketSource(800, 100, 1000, 14, 22, 16)
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, 00:01:0e:03:05:02)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(22)
  -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
 -> TODEVICE;
    
Script(
  wait RUNTIME,
  stop
);
