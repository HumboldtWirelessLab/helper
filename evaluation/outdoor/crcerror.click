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
  -> brnpacket_clf :: Classifier(30/8087, - )
  -> BRN2CRCerror()
  -> Discard;

brnpacket_clf[1]
  -> Discard;

status_clf[1]
  -> Discard;

Script(
	wait 6,
	stop
);
  