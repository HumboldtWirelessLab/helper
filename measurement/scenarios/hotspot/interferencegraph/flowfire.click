BRNAddressInfo(my_wlan NODEDEVICE:eth);
q::NotifierQueue(500)

FROMRAWDEVICE(NODEDEVICE)
 -> Discard;

qc::BRN2PacketQueueControl(QUEUESIZEHANDLER q.length, QUEUERESETHANDLER q.reset, MINP 100 , MAXP 200, DEBUG 4)
 -> EtherEncap(0x0800, my_wlan , ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRates(RATE0 22, RATE1 2, RATE2 2, RATE3 2, TRIES0 1, TRIES1 0, TRIES2 0, TRIES3 0)
 -> SetTXRate(2)
 -> SetTXPower(15)
 -> q
 -> SetTimestamp()
 -> Print(TIMESTAMP true)
 -> cnt::Counter()
 -> TODEVICE(NODEDEVICE);

Script(
 wait 1,
 loop ); 