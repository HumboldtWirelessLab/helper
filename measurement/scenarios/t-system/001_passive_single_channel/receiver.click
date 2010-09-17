BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//  -> p::Counter()
    -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> td :: ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");
//  -> Discard;

FromDevice(eth0, PROMISC true)
//-> mc::Classifier(0/ffffffff,-)
-> Print()
-> th::ToHost(eth0);

//mc[1]
//-> th;

//Idle
//-> mc2::Classifier(12/0800,-)
//-> Strip(14)
//-> CheckIPHeader()
//-> IPClassifier(dst udp port 60000)
//-> StripIPHeader()
//-> Strip(8)
//-> Print("Sync")
//-> Discard;

//mc2[1]
//-> Discard;

//Script(wait 5, read p.byte_count);
