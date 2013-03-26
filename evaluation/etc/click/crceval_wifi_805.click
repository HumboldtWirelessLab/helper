FromDump("DUMP",STOP true)
//COMPRESSION -> pdc::PacketDecompression(CMODE 0)
//COMPRESSION -> n::Null();
//COMPRESSION pdc[1]
//COMPRESSION -> n
  -> packets :: Counter
  -> maxl :: CheckLength(4)
  -> minl :: CheckLength(3)[1]
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
  -> Discard;

error_clf[1]
  -> crc :: Counter
  -> PrintCRCError(LABEL "CRC", RATE 0, OFFSET 44, ANALYSE true, BITS 8, PAD 3000)
  -> Discard;

ath2_decap[2]
  -> Discard;

filter_tx[1]
  -> Discard;

ath2_decap[1]
  -> Discard;

//ATH athp[1]
//ATH  -> Print("DumpError", TIMESTAMP true)
//ATH  -> maxathl;
