FromDump("DUMP",STOP true)
  -> packets :: Counter
  -> Strip(14)
//GPS  -> GPSPrint(NOWRAP true)
//GPS  -> GPSDecap()
  -> filter_tx :: FilterTX()
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("Seq", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> BRN2PrintWifi("TXFeedback", TIMESTAMP true)
  -> Discard;
