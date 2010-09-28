BRNAddressInfo(my_wlan NODEDEVICE:eth);

//FROMRAWDEVICE(NODEDEVICE)
//  -> ath2_decap :: Ath2Decap(ATHDECAP true)                                                                                                                                                                                                                           
//  -> filter_tx :: FilterTX()          
//  -> Discard;
//  filter_tx[1]
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.dump");

ps::BRN2PacketSource(SIZE 240, INTERVAL 20, MAXSEQ 500000, BURST 1, ACTIVE false)
  -> EtherEncap(0x8088, my_wlan,  06:11:6B:61:CF:B5 ) //06:0B:6B:09:ED:73
  -> WifiEncap(0x00, 0:0:0:0:0:0)
//  -> SetTXRates(RATE0 2, TRIES0 7, RATE1 2, TRIES1 7, RATE2 2, TRIES2 7, RATE3 2, TRIES3 7)
  -> SetTXRate(RATE 12, TRIES 11)
  -> wlan_out::SetTXPower(15);

wlan_out
  -> __WIFIENCAP__
  -> SetTimestamp()
  -> rawouttee :: Tee()
  -> fdq :: FrontDropQueue(64)
  //-> af::AgeFilter(MAXAGE 3000ms)
  -> TORAWDEVICE(NODEDEVICE);

rawouttee[1]
  -> SetTimestamp()
  -> tdout :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

fdq[1]
  -> SetTimestamp()
  -> dd::ToDump("RESULTDIR/NODENAME.NODEDEVICE.drop.dump");

//af[1]
//  -> dd;

SYNC
  -> tdout;
