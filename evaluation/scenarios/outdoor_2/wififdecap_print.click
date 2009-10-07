FromDump("NODE.DEVICE.dump")
-> BRN2PrintWifi("Packet",TIMESTAMP true)
-> Discard;

  
Script(
	wait 10,
	stop
);
  