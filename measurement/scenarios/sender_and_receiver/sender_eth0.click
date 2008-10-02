AddressInfo(my_wlan eth1:eth);

BRN2PacketSource(1000, 1, 0, 1, 1, 1)
 -> EtherEncap(0x8087, my_wlan, 00:13:77:4C:08:77 )
 -> wlan_out_queue :: NotifierQueue(10000);

BRN2PacketSource(1000, 1, 0, 1, 1, 1)
 -> EtherEncap(0x8088, my_wlan, 00:13:77:4C:08:77 )
 -> wlan_out_queue;

wlan_out_queue
-> ToDevice(eth1);

Script(
  wait 120,
  stop
);
