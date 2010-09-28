#ifndef WIFITYPE
#define WIFITYPE 805
#endif

#define ns 800
#define extra 806

#if WIFITYPE == 801
#define WIFIENCAP Null()
#define WIFIDECAP Null()
#endif

#if WIFITYPE == 802
#define WIFIENCAP RadiotapEncap()
#define WIFIDECAP RadiotapDecap()
#endif

#if WIFITYPE == 803
#define WIFIENCAP Prism2Encap()
#define WIFIDECAP Prism2Decap()
#endif

#if WIFITYPE == 804
#define WIFIENCAP AthdescEncap()
#define WIFIDECAP AthdescDecap()
#endif

#if WIFITYPE == 805
#define WIFIENCAP Ath2Encap(ATHENCAP true)
#define WIFIDECAP Ath2Decap(ATHDECAP true)
#endif

#if WIFITYPE == ns
#define WIFIENCAP AddEtherNsclick()
#define WIFIDECAP Strip(14)
#endif

#if WIFITYPE == extra
#define WIFIENCAP ExtraEncap()
#define WIFIDECAP ExtraDecap()
#endif

#undef ns
#undef extra

/* KERNEL stuff */

#ifdef KERNEL
#define FROMRAWDEVICE  FromDevice(NODEDEVICE)
#define TORAWDEVICE  ToDevice(NODEDEVICE)

#define FROMDEVICE FROMRAWDEVICE -> WIFIDECAP
#define TODEVICE WIFIENCAP -> TORAWDEVICE

#ifdef REMOTEDUMP
BRNAddressInfo(ethdev eth0:eth);
BRNAddressInfo(ipdev eth0:ip);					   
#endif

#define DUMPPORTBASE DUMPPORT@__LINE__

#define TODUMP(X) UDPIPEncap(SRC ipdev, SPORT 30000, DST DUMPIP, DPORT DUMPPORTBASE, CHECKSUM false, ALIGNFIX true) \
                   ->EtherEncap(ETHERTYPE 0x0800, SRC ethdev, DST DUMPMAC) \
		   ->ethq::SimpleQueue(CAPACITY 500) \
		   ->ToDevice(eth0)

#define SYNC FromHost(sync0,192.168.20.1/24) \
             ->fhc::Classifier(12/0806,12/0800) \
	     ->ARPResponder(0.0.0.0/0 1:1:1:1:1:1) \
	     ->ToHost(sync0); \
	     fhc[1] \
	     ->Strip(14) \
	     ->MarkIPHeader() \
	     ->StripIPHeader() \
	     ->max::CheckLength(12)[1] \
	     ->Discard; \
	     max[0] \
	     ->Strip(8) \
	     //->Print(TIMESTAMP\ttrue)
#endif

/* USERLEVEL stuff */

#ifdef USERLEVEL
#define FROMRAWDEVICE FromDevice(NODEDEVICE, PROMISC true, OUTBOUND true, SNIFFER false)
#define TORAWDEVICE ToDevice(NODEDEVICE)

#define FROMDEVICE FROMRAWDEVICE -> WIFIDECAP
#define TODEVICE WIFIENCAP -> TORAWDEVICE

#ifdef REMOTEDUMP
BRNAddressInfo(ethdev eth0:eth);
BRNAddressInfo(ipdev eth0:ip);					   

#define DUMPPORTBASE DUMPPORT@__LINE__
#define TODUMP(x) Socket(UDP, DUMPIP, DUMPPORTBASE, CLIENT true ) \
                  -> Discard
#else
#define TODUMP ToDump
#endif


#define SYNC Idle \
              ->Socket(UDP,0.0.0.0,60000) \
	      ->Print("Sync",TIMESTAMP true)

#endif


/* SIMULATION stuff */

#ifdef SIMULATION

#define FROMRAWDEVICE FromSimDevice(NODEDEVICE,4096)
#define TORAWDEVICE ToSimDevice(NODEDEVICE)

#define TODEVICE WIFIENCAP -> TORAWDEVICE
#define FROMDEVICE FROMRAWDEVICE -> WIFIDECAP

#define TODUMP ToDump

#define SYNC Null()

#endif
