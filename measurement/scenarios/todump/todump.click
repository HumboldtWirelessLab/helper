AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
 -> ToDump("RESULTDIR/NODE.DEVICE.dump");

Script(
  wait RUNTIME,
  stop
);
