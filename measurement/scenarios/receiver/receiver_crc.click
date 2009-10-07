BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> Ath2Decap( ATHDECAP true )
  -> ftx :: FilterTX()
  -> error_clf :: WifiErrorClassifier();

error_clf[0]
-> Discard;

error_clf[1]
-> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

error_clf[2]
-> ptd :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.pdump");
  
Script(
  wait RUNTIME,
  stop
);
