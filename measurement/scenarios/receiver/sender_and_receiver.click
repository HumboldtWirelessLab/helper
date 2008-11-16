BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> AthdescDecap()
  -> Strip(11)
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

BRN2PacketSource(1000, 100, 1000, 14, 22, 16)
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, 00:01:0e:03:05:02)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(22)
  -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
 -> SetTXPower(3)
 -> TODEVICE;
    
Script(
  wait RUNTIME,
  stop
);
