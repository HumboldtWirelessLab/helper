BRNAddressInfo(my_wlan NODEDEVICE:eth);

//AddressInfo(dst 10.0.0.1 06-0F-B5-0B-A8-92); //wgt76
AddressInfo(dst 10.0.0.1 06-0B-6B-09-F2-94); //sk111
//AddressInfo(dst 10.0.0.1 06-11-6B-61-CF-B6);
//AddressInfo(dst 10.0.0.1 06-0F-B5-97-34-E9)  //wgt52

wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS my_wlan, DEVICETYPE "WIRELESS");

id::BRN2NodeIdentity(NAME NODENAME, DEVICES wireless);


FROMRAWDEVICE(NODEDEVICE)
-> t::Tee()
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

t[1]
-> dev_decap::__WIFIDECAP__
-> Discard;

dev_decap[1]
 -> rawwifidev_too_small_cnt::Counter
 -> Discard;

ps::BRN2PacketSource(SIZE 100, INTERVAL 100, MAXSEQ 500000, BURST 1, ACTIVE false)
 -> rrs :: RoundRobinSwitch()
 -> sender_suppressor::Suppressor()
 -> ee::EtherEncap(0x8088, my_wlan, dst)
// -> EtherEncap(0x8088, dst, dst)
// -> EtherEncap(0x8088, 00:0c:0c:0c:0c:03, dst)
 -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
 -> data_rate::SetTXRate(RATE 12, TRIES 7)
// -> SetTXRate(12)
 -> wlan_out_queue :: NotifierQueue(100)
 -> queue_suppressor::Suppressor()
 -> SetTXPower(15)
 -> Print("Out")
 -> __WIFIENCAP__
 -> [1]op_prio_s::PrioSched()
 -> tor::TORAWDEVICE(NODEDEVICE);

dev_decap[2]
 -> ath_op::Ath2Operation(DEVICE wireless, READCONFIG true, DEBUG 2)
 -> ath_op_q::NotifierQueue(10)
 -> op_prio_s;

//rrs[1]
// -> EtherEncap(0x8088, dst, dst)  //sk111
//// -> EtherEncap(0x8088, 06:0B:6B:09:ED:73, dst)  //sk110
//// -> EtherEncap(0x8088, 00:0c:0c:0c:0c:04, dst)
// -> wifienc;
