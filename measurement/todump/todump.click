AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
 -> ToDump("/home/sombrutz/Download/r.dump");

Script(
  wait RUNTIME,
  stop
);
