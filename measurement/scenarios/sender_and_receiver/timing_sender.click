BRNAddressInfo(my_wlan NODEDEVICE:eth);

rrs::RoundRobinSched();

BRN2PacketSource(1400, 12, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue1 :: NotifierQueue(1000)
 -> [0]rrs;

BRN2PacketSource(50, 12, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue2 :: NotifierQueue(1000)
 -> [1]rrs;	  
 
rrs
-> SetTXPower(16)
-> TODEVICE;

FROMRAWDEVICE
 -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

Script(
  wait RUNTIME,
  stop
);
