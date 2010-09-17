BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

FromDevice(eth0)
  -> mc::Classifier(0/ffffffff 12/0800,-)
  -> Strip(14)
  -> MarkIPHeader()
  -> StripIPHeader()
  -> udpc::Classifier(2/ea60,-)
  -> Null()
  -> Strip(8)
  -> td;

th::ToHost(eth0);

udpc[1]
  -> UnstripIPHeader()
  -> Unstrip(14)
  -> th;

mc[1]
  -> th;
