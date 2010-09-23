FromDump("DUMP",STOP true)
  -> packets :: Counter
//GPS  -> GPSPrint(NOWRAP true)
//GPS  -> GPSDecap()
//ATH  -> Ath2Print(INCLUDEATH true, NOWRAP true)
  -> ath2_decap :: Ath2Decap(ATHDECAP true)
  -> filter_tx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();

error_clf[0]
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("Sequence:", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

error_clf[1]
  -> crc :: Counter
  -> maxcrclen :: CheckLength(1500)
  -> BRN2PrintWifi("CRCerror", TIMESTAMP true)
  -> Discard;

  maxcrclen[1]
  -> Discard;

error_clf[2]
  -> phy :: Counter
  -> maxphylen :: CheckLength(1500)
  -> BRN2PrintWifi("PHYerror", TIMESTAMP true)
  -> Discard;

  maxphylen[1]
  -> Discard;

error_clf[3]
  -> fifo :: Counter
  -> BRN2PrintWifi("FifoError", TIMESTAMP true)
  -> Discard;

error_clf[4]
  -> decrypt :: Counter
  -> BRN2PrintWifi("DecryptError", TIMESTAMP true)
  -> Discard;

error_clf[5]
  -> mic :: Counter
  -> BRN2PrintWifi("MICerror", TIMESTAMP true)
  -> Discard;

error_clf[6]
  -> zerorate :: Counter
  -> BRN2PrintWifi("ZeroRateError", TIMESTAMP true)
  -> Discard;

error_clf[7]
  -> unknown :: Counter
  -> BRN2PrintWifi("UNKNOWNerror", TIMESTAMP true)
  -> Discard;

ath2_decap[2]
  -> Print("ATHOPERATION", TIMESTAMP true)
  -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> BRN2PrintWifi("TXFeedback", TIMESTAMP true)
  -> Discard;

ath2_decap[1]
  -> maxl :: CheckLength(4)
  -> minl :: CheckLength(3)[1]
  -> Print("Sync", TIMESTAMP true)
  -> toosmall :: Counter
  -> Discard;

  maxl[1]
  -> Print("DumpError", TIMESTAMP true)
  -> Discard;
  
  minl
  -> Print("DumpError", TIMESTAMP true)
  -> Discard;
