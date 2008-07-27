AddressInfo(my_wlan eth0:eth);

FromDevice(eth0)
  -> rawtee :: Tee()
  -> Discard();
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/NODE.DEVICE.dump");
  
Script(
  wait RUNTIME,
  stop
);
