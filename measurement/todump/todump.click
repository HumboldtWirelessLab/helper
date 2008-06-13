AddressInfo(my_wlan DEVICE:eth);

FROMRAWDEVICE
 -> ToDump("/home/sombrutz/Download/r.dump");

Script(
  wait RUNTIME,
  stop
);
