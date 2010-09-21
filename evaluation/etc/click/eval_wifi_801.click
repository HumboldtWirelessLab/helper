FromDump("DUMP",STOP true)
  -> packets :: Counter
//GPS  -> GPSPrint(NOWRAP true)
//GPS  -> GPSDecap()
  -> rtap_decap :: RadiotapDecap()
  -> filter_tx :: FilterTX()
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("Ether", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> BRN2PrintWifi("TXFeedback", TIMESTAMP true)
  -> Discard;
