AddressInfo(my_wlan DEVICE:eth);

<<<<<<< HEAD:measurement/todump/todump.click
FROMDEVICE
 -> ToDump("RESULTDIR/NODE.DEVICE.dump");
=======
FROMRAWDEVICE
 -> ToDump("/home/sombrutz/Download/r.dump");
>>>>>>> dc69b9d808723132f434925e6192f0650f849352:measurement/todump/todump.click

Script(
  wait RUNTIME,
  stop
);
