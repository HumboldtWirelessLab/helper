tun :: KernelTun(192.168.1.1/24);

tun
  -> fromVA :: IPClassifier( dst udp port 10000, - )
  -> Print("From VA")
  -> StripIPHeader()
  -> Strip(8)
  -> tun
  
fromVA[1]
  -> Print("From Net")
  -> packet_encap :: UDPIPEncap( 192.168.1.4 , 10000 , 192.168.4.3 , 11000, true )  
  -> tun

Script(
    wait RUNTIME,
    stop
);
