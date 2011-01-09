BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(SIZE 1000, INTERVAL 100, MAXSEQ 500000, BURST 1, ACTIVE true)
//BRN2PacketSource(VAR_PSIZE, VAR_RATE, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, 06:0b:6b:09:ef:73)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> data_rate::SetTXRate(RATE 108, TRIES 11)
// -> SetTXRate(12)
 -> wlan_out_queue :: NotifierQueue(500);

wlan_out_queue
-> SetTXPower(1)
-> TODEVICE(NODEDEVICE);

FROMDEVICE(NODEDEVICE)
-> PrintWifi()
-> Discard;


wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS my_wlan, DEVICETYPE "WIRELESS");

Idle
-> ath_op::Ath2Operation(DEVICE wireless, READCONFIG false, DEBUG 2)
-> Discard;
