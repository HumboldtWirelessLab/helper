tun :: KernelTun(1.0.0.1/24);
tunnet :: KernelTun(192.168.1.1/24);
//tunnet2 :: KernelTun(192.168.2.1/24);

tun
  -> fromVA :: IPClassifier( dst udp port 10002, - )
//  -> Print("From VA",100)
  -> StripIPHeader()
  -> Strip(8)
//  -> Print("to net")
  -> CheckIPHeader(0)
//  -> Print("Check IP")
  -> ipqueue :: NotifierQueue(500)
  -> tunnet
  
fromVA[1]
  -> Print("Upps")
  -> Discard();
  
tunnet
//  -> Print("From Net ?") 
  -> packet_encap :: UDPIPEncap( 1.0.0.4 , 10002 , 192.168.4.3 , 11000, true )  
//  -> CheckIPHeader(0)
  -> ipqueue2 :: NotifierQueue(500)
//  -> Print("to VA")
  -> tun

Script(
    wait RUNTIME,
    stop
);
