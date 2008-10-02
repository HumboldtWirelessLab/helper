FromDump("NODE.DEVICE.dump")
  -> packets :: Counter
//-> length :: CheckLength(43)
  -> AthdescDecap()
  -> filter_tx :: FilterTX()
  -> filter_phy :: FilterPhyErr()
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> Discard;
  
Script(
	wait 6,
	stop
);
  