FROMRAWDEVICE
  -> rawtee :: Tee()
  -> Discard();
  
  rawtee[1]
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

Script(
  wait RUNTIME,
  stop
);
