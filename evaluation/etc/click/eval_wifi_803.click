FromDump("DUMP", MMAP true, STOP true)
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
  -> rtap_decap :: RadiotapDecap(DEBUG true)
//  -> Print("OK",200)
  -> filter_tx :: FilterTX()
  -> filter_err :: FilterPhyErr()
  -> ok :: Counter
  -> BRN2PrintWifi("OKPacket",TIMESTAMP true)
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

filter_err[1]
  -> txphy :: Counter
  -> BRN2PrintWifi("CRCerror", TIMESTAMP true)
  -> Discard;

