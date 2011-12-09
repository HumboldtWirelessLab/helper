FromDump("DUMP",STOP true)
//COMPRESSION -> pdc::PacketDecompression(CMODE 0)
//COMPRESSION -> n::Null();
//COMPRESSION pdc[1]
//COMPRESSION -> n
  -> packets :: Counter
  -> sync1 :: CheckLength(4)[1]
//GPS  -> GPSPrint(NOWRAP true)
//GPS  -> GPSDecap()
//ATH  -> athp::Ath2Print(INCLUDEATH true, NOWRAP true)
  -> ath2_decap :: Ath2Decap(ATHDECAP true)
  -> filter_tx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();


error_clf[0]
  -> ok :: Counter
  -> PrintWifiRaw("OKPacket",TIMESTAMP true)
  -> WifiDecap()
//SEQ  -> seq_clf :: Classifier( 12/8088, - )
//SEQ  -> Print("Sequence:", TIMESTAMP true)
  -> Discard;

//SEQ seq_clf[1]
//SEQ -> Discard;

error_clf[1]
  -> crc :: Counter
  -> maxcrclen :: CheckLength(1500)
  -> PrintWifiRaw("CRCerror", TIMESTAMP true)
  -> Discard;

  maxcrclen[1]
  -> PrintWifiRaw("CRC_TO_LONGerror", TIMESTAMP true)
  -> Discard;

error_clf[2]
  -> phy :: Counter
  -> maxphylen :: CheckLength(1500)
  -> minphylen :: CheckLength(13)[1]
  -> PrintWifiRaw("PHYerror", TIMESTAMP true)
  -> Discard;

  maxphylen[1]
  -> PrintWifiRaw("PHY_TO_LONGerror", TIMESTAMP true)
  -> Discard;

  minphylen[0]
  -> Print("PHY_TO_SHORTerror", TIMESTAMP true)
  -> Discard;

error_clf[3]
  -> fifo :: Counter
  -> PrintWifiRaw("FifoError", TIMESTAMP true)
  -> Discard;

error_clf[4]
  -> decrypt :: Counter
  -> PrintWifiRaw("DecryptError", TIMESTAMP true)
  -> Discard;

error_clf[5]
  -> mic :: Counter
  -> PrintWifiRaw("MICerror", TIMESTAMP true)
  -> Discard;

error_clf[6]
  -> zerorate :: Counter
  -> PrintWifiRaw("ZeroRateError", TIMESTAMP true)
  -> Discard;

error_clf[7]
  -> unknown :: Counter
  -> PrintWifiRaw("UNKNOWNerror", TIMESTAMP true)
  -> Discard;

ath2_decap[2]
  -> Print("ATHOPERATION", TIMESTAMP true)
  -> Discard;

filter_tx[1]
  -> txpa :: Counter
  -> PrintWifiRaw("TXFeedback", TIMESTAMP true)
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

//ATH athp[1]
//ATH  -> maxl;

sync1[0]
  -> maxl;
