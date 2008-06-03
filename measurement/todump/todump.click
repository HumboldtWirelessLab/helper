AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
 -> ToDump("/home/sombrutz/Download/r.dump");

Script(                                                                                                                                                                                                             
  wait 20,                                                                                                                                                                                                      
  stop                                                                                                                                                                                                            
);
