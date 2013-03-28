#include "dht/routing/dht_dart.click"
#include "dht/routing/dht_falcon.click"
#include "dht/routing/dht_klibs.click"
#include "dht/routing/dht_omni.click"
#include "dht/storage/dht_storage.click"

elementclass DHT { ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug |

#ifdef DHTOMNI
  dhtrouting::DHT_OMNI(ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug);
#define HAVEDHT
#else
#ifdef DHTKLIBS
  dhtrouting::DHT_KLIBS(ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug);
#define HAVEDHT
#else
#ifdef DHTFALCON
  dhtrouting::DHT_FALCON(ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug);
#define HAVEDHT
#else
#ifdef DHTDART
  dhtrouting::DHT_DART(ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug);
#define HAVEDHT
#endif
#endif
#endif
#endif

#ifndef HAVEDHT
  dhtrouting::DHT_FALCON(ETHERADDRESS $etheraddress, LINKSTAT $lt, STARTTIME $starttime, UPDATEINT $updateint, DEBUG $debug);
#endif

  dhtstorage::DHT_STORAGE(DHTROUTING dht/dhtrouting, DEBUG $debug);

  input[0]
  -> BRN2Decap()
  -> [0]dhtrouting[0]
  -> [1]output;

  input[1]
  -> BRN2Decap()
  -> dhtstorage
  -> [1]output;

  dhtrouting[1]
  -> [0]output;

}
