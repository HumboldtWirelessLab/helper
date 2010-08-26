BRNAddressInfo(my_wlan NODEDEVICE:eth);

//FROMRAWDEVICE
//  -> ath2_decap :: Ath2Decap(ATHDECAP true)                                                                                                                                                                                                                           
//  -> filter_tx :: FilterTX()          
//  -> Discard;
//  filter_tx[1]
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.dump");

ps::BRN2PacketSource(240, 20, 500000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan,  06:0B:6B:09:ED:73 )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(12)
  -> wlan_out::SetTXPower(15);
	  
wlan_out
  -> WIFIENCAPTMPL
  -> SetTimestamp()
  -> rawouttee :: Tee()
  -> fdq :: FrontDropQueue(64)
  -> TORAWDEVICE;

rawouttee[1]
  -> tdout :: ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.out.dump");
//  -> tdout :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

  fdq[1]
  -> ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.drop.dump");
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.drop.dump");

Idle                                                                                                                                                                                                                                                              
  -> Socket(UDP, 0.0.0.0, 60000)                                                                                                                                                                                                                                    
  -> Print("Sync",TIMESTAMP true)                                                                                                                                                                                                                                   
  -> tdout;

Script(
  wait 110,
  write ps.active false
);

Script(
  wait RUNTIME,
  stop
);
