FromDump("DUMP",STOP true)
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
//  -> Print("CRCerror",TIMESTAMP true)
  -> PrintWifi("CRCerror",TIMESTAMP true)
  -> Discard;

error_clf[2]
  -> phy :: Counter
  -> Print("Phy", TIMESTAMP true)
  -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> PrintWifi("TXFeedback",TIMESTAMP true)
  -> Discard;
  
ath2_decap[1]
  -> toosmall :: Counter
  -> Discard;
