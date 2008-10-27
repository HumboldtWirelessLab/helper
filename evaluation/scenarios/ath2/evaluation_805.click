FromDump("sk110.ath0.dump")
  -> packets :: Counter
  -> Ath2Print(COMPLATH 1)
  -> AthdescDecap()
  -> filter_tx :: FilterTX()
  -> status_clf :: Classifier(2/00%ff, // 0 => recv ok
                              2/01%ff, // CRC error on frame
                              2/02%ff, // PHY error, rs_phyerr is valid
                              2/04%ff, // fifo overrun
                              -        // decrypt stuff
                              );
			      
status_clf[0]
  -> ok :: Counter
//  -> Ath2Print()
  -> Ath2Decap()
  -> PrintWifi("OKPacket",TIMESTAMP true)
  -> Discard;

status_clf[1]
  -> crc :: Counter
//  -> Ath2Print()
  -> Ath2Decap() 
//  -> PrintWifi("CRCerror",TIMESTAMP true)
  -> Discard;

status_clf[2]
  -> phy :: Counter
//  -> Ath2Print()
  -> Ath2Decap() 
//  -> BRN2PrintWifi("Phyerror",TIMESTAMP true)
  -> Discard;

status_clf[3]
  -> fifo :: Counter
  -> Discard;

status_clf[4]
  -> crypt :: Counter
  -> Discard;

filter_tx[1]
  -> txpa :: Counter
//  -> Ath2Print()
  -> Ath2Decap() 
//  -> BRN2PrintWifi("TXFeedback",TIMESTAMP true)
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
	
	read txpa.count,
	read txpa.rate,	
	
	stop
);
  