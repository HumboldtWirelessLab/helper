FromDump("NODE.DEVICE.dump")
  -> packets :: Counter
//-> length :: CheckLength(43)
  -> AthdescDecap()
  -> filter_tx :: FilterTX()
  -> status_clf :: Classifier(4/00%ff, // 0 => recv ok
                              4/01%ff, // CRC error on frame
                              4/02%ff, // PHY error, rs_phyerr is valid
                              4/04%ff, // fifo overrun
                              -        // decrypt stuff
                              );
			      
status_clf[0]
  -> ok :: Counter
  -> Strip(11)
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
//-> PrintWifi("OKPacket",TIMESTAMP true)
  -> Discard;

status_clf[1]
  -> crc :: Counter
  -> Strip(11)
  -> BRN2PrintWifi("CRCerror",TIMESTAMP true)
//-> PrintWifi("CRCerror",TIMESTAMP true)
  -> Discard;

status_clf[2]
  -> phy :: Counter
  -> Strip(11)
  -> BRN2PrintWifi("Phyerror",TIMESTAMP true)
//-> PrintWifi("Phyerror",TIMESTAMP true)
  -> Discard;

status_clf[3]
  -> fifo :: Counter
  -> Discard;

status_clf[4]
  -> crypt :: Counter
  -> Discard;

filter_tx[1]
  -> Strip(11)
  -> BRN2PrintWifi("TXFeedback",TIMESTAMP true)
//-> PrintWifi("TXFeedback",TIMESTAMP true)
  -> Discard;
  
Script(
	wait 6,
	
	read packets.count,
	read packets.rate,
	
	read ok.count,
	read ok.rate,

	read crc.count,
	read crc.rate,

	read phy.count,
	read phy.rate,

	read fifo.count,
	read fifo.rate,

	read crypt.count,
	read crypt.rate,	
	stop
);
  