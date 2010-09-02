BRNAddressInfo(my_wlan NODEDEVICE:eth);

//FROMRAWDEVICE
//  -> ath2_decap :: Ath2Decap(ATHDECAP true)                                                                                                                                                                                                                           
//  -> filter_tx :: FilterTX()          
//  -> Discard;
//  filter_tx[1]
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.dump");

ps::BRN2PacketSource(SIZE 240, INTERVAL 20, MAXSEQ 500000, BURST 1, ACTIVE false)
  -> EtherEncap(0x8088, my_wlan,  06:0B:6B:09:ED:73 )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRates(RATE0 12, TRIES0 7, RATE1 12, TRIES1 7, RATE2 12, TRIES2 7, RATE3 12, TRIES3 7)
//-> SetTXRate(RATE 12, TRIES 11)
  -> wlan_out::SetTXPower(15);
	  
wlan_out
  -> WIFIENCAPTMPL
  -> SetTimestamp()
  -> rawouttee :: Tee()
  -> fdq :: FrontDropQueue(64)
  -> TORAWDEVICE;

rawouttee[1]
  -> tdout :: ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.out.dump");
  //-> tdout :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

  fdq[1]
  -> ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.drop.dump");
  //-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.drop.dump");

Idle                                                                                                                                                                                                                                                              
  -> Socket(UDP, 0.0.0.0, 60000)                                                                                                                                                                                                                                    
  -> Print("Sync",TIMESTAMP true)                                                                                                                                                                                                                                   
  -> tdout;

Script(
  wait 120,
  write ps.active true,
  wait 110,
  write ps.active false
);

Script(
  wait RUNTIME,
  stop
);
