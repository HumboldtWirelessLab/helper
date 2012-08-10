  // Configure IP addresses
  Ipv4AddressHelper ipv4;
  ipv4.SetBase ("172.16.1.0", "255.255.255.0");
  ipv4.Assign (wifiDevices);
  

  // For tracing
  wifiPhy.EnablePcap ("SIMNAME", wifiDevices);

  Simulator::Stop (Seconds (SIMDURATION));
  Simulator::Run ();

  Simulator::Destroy ();
  return 0;
#else
  NS_FATAL_ERROR ("Can't use ns-3-click without NSCLICK compiled in");
#endif
}
