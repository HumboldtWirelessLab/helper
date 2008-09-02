rc :: BrnRouteCache(ACTIVE false, DROP /* 1/20 = 5% */ 0, SLICE /* 100ms */ 0, TTL /* 4*100ms */4);
lt :: BrnLinkTable(rc, STALE 500,  SIMULATE false, CONSTMETRIC 1, MIN_LINK_METRIC_IN_ROUTE 15000);
id :: NodeIdentity(eth0, eth0, eth0, lt);
rates :: AvailableRates(DEFAULT 2 4 11 12 18 22);
etx_metric :: BRNETXMetric(LT lt);

link_stat :: BRNLinkStat(ETHTYPE 0x0a04,
    NODEIDENTITY id,
    PERIOD 3000,
    TAU 30000,
    ETX etx_metric,
    PROBES "22 250",
    RT rates);

Idle
-> link_stat
-> Discard;

//dhtrouting :: DHTRoutingOmni(LINKSTAT link_stat);
dhtrouting :: DHTRoutingFalcon();

Idle
-> [0]dhtrouting[0]
-> Discard;

Idle
-> [1]dhtrouting[1]
-> Discard;

dhtstorage :: DHTStorageSimple( DHTROUTING dhtrouting );

Idle
-> dhtstorage
-> Discard;

