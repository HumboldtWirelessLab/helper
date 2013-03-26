FromDump("DUMP",STOP true)
//COMPRESSION -> pdc::PacketDecompression(CMODE 0)
//COMPRESSION -> n::Null();
//COMPRESSION pdc[1]
//COMPRESSION -> n
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
//ATH  -> athp::Ath2Print(INCLUDEATH true, NOWRAP true)
  -> ath2_decap :: Ath2Decap(ATHDECAP true)
  -> filter_tx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();


error_clf[0]
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("ReferenceSignal", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

error_clf[1]
  -> crc :: Counter
  //TODO: check for max 802.11n PDU
  -> maxcrclen :: CheckLength(8600)
  -> BRN2PrintWifi("CRCerror", TIMESTAMP true)
  -> Discard;

  maxcrclen[1]
  -> BRN2PrintWifi("CRC_TO_LONGerror", TIMESTAMP true)
  -> Discard;

error_clf[2]
  -> phy :: Counter
  -> maxphylen :: CheckLength(8600)
  -> minphylen :: CheckLength(13)[1]
  -> BRN2PrintWifi("PHYerror", TIMESTAMP true)
  -> Discard;

maxphylen[1]
  -> BRN2PrintWifi("PHY_TO_LONGerror", TIMESTAMP true)
  -> Discard;

  minphylen[0]
  -> BRN2PrintWifi("PHY_TO_SHORTerror", TIMESTAMP true)
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
  -> phantom :: Counter
  -> BRN2PrintWifi("Phantom", TIMESTAMP true)
  -> Discard;

error_clf[8]
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
  -> maxathl :: CheckLength(4)
  -> minathl :: CheckLength(3)[1]
  -> Print("Sync", TIMESTAMP true)
  -> toosmall2 :: Counter
  -> Discard;

  maxathl[1]
  -> Print("DumpError", TIMESTAMP true)
  -> Discard;

  minathl
  -> Print("DumpError", TIMESTAMP true)
  -> Discard;

//ATH athp[1]
//ATH  -> Print("DumpError", TIMESTAMP true)
//ATH  -> maxathl;
