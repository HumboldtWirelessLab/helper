BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//-> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
  -> tdraw :: ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.dump");
  

Idle                                                                                                                                                                                                                                                              
  -> Socket(UDP, 0.0.0.0, 60000)                                                                                                                                                                                                                                    
  -> Print("Sync",TIMESTAMP true)                                                                                                                                                                                                                                   
  -> tdraw;

Script(
  wait RUNTIME,
  stop
);
