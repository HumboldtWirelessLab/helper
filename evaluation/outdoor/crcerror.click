FromDump("NODE.DEVICE.dump")
  -> length :: CheckLength(43)
  -> Discard;

  length[1]
  -> AthdescDecap()
  -> filter_tx :: FilterTX()
  -> status_clf :: Classifier(4/01%ff, // CRC error on frame
                              -
                              );
			      
status_clf[0]
  -> Strip(11)
  -> WifiDecap()
  -> brnpacket_clf :: Classifier(12/8087, - )
  -> EtherDecap()
  -> maxlen :: CheckLength(MAXLEN)
  -> minlen :: CheckLength(MINLEN)
  -> Discard;
  
  minlen[1]
  -> BRN2CRCerror("",BITRATE)
  -> Discard;

brnpacket_clf[1]
  -> Discard;

status_clf[1]
  -> Discard;

Script(
	wait 6,
	stop
);
  