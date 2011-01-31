#ifndef WIFITYPE
#warning No Wifitype. Using default (805).
#define WIFITYPE 805
#endif

#define ns 800
#define extra 806

#if WIFITYPE == 801
#define __WIFIENCAP__ Null()
#define __WIFIDECAP__ Null()
#endif

#if WIFITYPE == 802
#define __WIFIENCAP__ BrnRadiotapEncap()
#define __WIFIDECAP__ RadiotapDecap()
#endif

#if WIFITYPE == 803
#define __WIFIENCAP__ Prism2Encap()
#define __WIFIDECAP__ Prism2Decap()
#endif

#if WIFITYPE == 804
#define __WIFIENCAP__ AthdescEncap()
#define __WIFIDECAP__ AthdescDecap()
#endif

#if WIFITYPE == 805
#define __WIFIENCAP__ Ath2Encap(ATHENCAP true)

#ifdef CST
#define __WIFIDECAP__ Ath2Decap(ATHDECAP true, CHANNELSTATS CST)
#else
#define __WIFIDECAP__ Ath2Decap(ATHDECAP true)
#endif

#endif

#if WIFITYPE == ns
#define __WIFIENCAP__ AddEtherNsclick()
#define __WIFIDECAP__ Strip(14)
#endif

#if WIFITYPE == extra
#define __WIFIENCAP__ ExtraEncap()
#define __WIFIDECAP__ ExtraDecap()
#endif

#undef ns
#undef extra


/* KERNEL stuff */

#ifdef KERNEL
#define FROMRAWDEVICE(x)  FromDevice(x)
#define TORAWDEVICE(x)  ToDevice(x)

#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__
#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)

#ifdef REMOTEDUMP
BRNAddressInfo(ethdev eth0:eth);
BRNAddressInfo(ipdev eth0:ip);					   
#endif

#define DUMPPORTBASE DUMPPORT@__LINE__

#define TODUMP(X) TimestampEncap() \
                   ->UDPIPEncap(SRC ipdev, SPORT 30000, DST DUMPIP, DPORT DUMPPORTBASE, CHECKSUM false, ALIGNFIX true) \
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
#ifdef RECEIVE_ONLY
#define FROMRAWDEVICE(x) FromDevice(x, PROMISC true, OUTBOUND true, SNIFFER false, CAPTURE PCAP/*, ENCAP 802_11*/)
#else
#define FROMRAWDEVICE(x) FromDevice(x, PROMISC true, OUTBOUND true, SNIFFER false/*, CAPTURE PCAP, ENCAP 802_11*/)
#endif
#define TORAWDEVICE(x) ToDevice(x, DEBUG false)

#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__
#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)

#ifdef REMOTEDUMP
BRNAddressInfo(ethdev eth0:eth);
BRNAddressInfo(ipdev eth0:ip);					   

#define DUMPPORTBASE DUMPPORT@__LINE__
#define TODUMP(x) TimestampEncap() \
                  -> Socket(UDP, DUMPIP, DUMPPORTBASE, CLIENT true ) \
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

#define FROMRAWDEVICE(x) FromSimDevice(x,4096)
#define TORAWDEVICE(x) ToSimDevice(x)

#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)
#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__

#define TODUMP ToDump

#define SYNC Null()

#endif
