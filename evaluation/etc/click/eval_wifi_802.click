FromDump("DUMP",STOP true)
  -> packets :: Counter
  -> maxl :: CheckLength(4)
  -> minl :: CheckLength(3)[1]
  -> Print("Sync", TIMESTAMP true)
  -> toosmall :: Counter
  -> Discard;
	    
minl
  -> Print("DumpError", TIMESTAMP true)
  -> Discard;
	       
maxl[1]
//GPS  -> GPSPrint(NOWRAP true)
//GPS  -> GPSDecap()
  -> rtap_decap :: BrnRadiotapDecap()
  -> filter_tx :: FilterTX()
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket", PRINTHT true, PRINTRXSTATUS true, TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("ReferenceSignal", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> BRN2PrintWifi("TXFeedback", TIMESTAMP true)
  -> Discard;
