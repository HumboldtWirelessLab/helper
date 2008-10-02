FromDump("WORKDIR/NODE.DEVICE.dump")
 -> AthdescDecap()
 -> pw :: PrintWifi(TIMESTAMP true)
 ->Discard;

Script(
  wait RUNTIME,
  stop
);
