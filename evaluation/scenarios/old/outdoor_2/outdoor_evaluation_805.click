FromDump("NODE.DEVICE.dump")
  -> Ath2Decap(ATHDECAP true)
  -> filter_tx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();
			      
error_clf[0]
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> Discard;

filter_tx[1]
//  -> Strip(11)
//  -> BRN2PrintWifi("TXFeedback",TIMESTAMP true)
  -> Discard;
  
Script(
	wait 10,
	stop
);
  