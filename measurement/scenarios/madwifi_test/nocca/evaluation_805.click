FromDump("sk112.ath0.raw.dump")
  -> packets :: Counter
  -> ath2_decap :: Ath2Decap(ATHDECAP true)
  -> filter_tx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();
			      
error_clf[0]
  -> ok :: Counter
  -> PrintWifi("OKPacket",TIMESTAMP true)
  -> Discard;

error_clf[1]
  -> crc :: Counter
  -> PrintWifi("CRCerror",TIMESTAMP true)
  -> Discard;

error_clf[2]
  -> phy :: Counter
  -> Print("Phy")
  -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> PrintWifi("TXFeedback",TIMESTAMP true)
  -> Discard;
  
ath2_decap[1]
  -> toosmall :: Counter
  -> Discard;

Script(
	wait 2,
	
	read packets.count,
	read packets.rate,
	
	read ok.count,
	read ok.rate,

	read crc.count,
	read crc.rate,

	read phy.count,
	read phy.rate,

	read txpa.count,
	read txpa.rate,	
	
	read toosmall.count,
	read toosmall.rate,
	
	stop
);
  