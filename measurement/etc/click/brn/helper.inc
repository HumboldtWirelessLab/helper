#ifndef __HELPER_INC__
#define __HELPER_INC__

/* NOPCAP (don't use pcap) is default */
#ifndef ENABLE_PCAP
#ifndef NOPCAP
#define NOPCAP
#endif
#endif

#ifndef PACKETBURST
#define PACKETBURST 1
#endif

#ifndef WIFITYPE
#warning No Wifitype. Using default (805).
#define WIFITYPE 805
#endif

#define ns 800
#define extra 806
#define openbeacon 807

#if WIFITYPE == 801
#define __WIFIENCAP__ Null()
#define __WIFIDECAP__ Null()
#endif

#if WIFITYPE == 802
#define __WIFIENCAP__ BrnRadiotapEncap()
#define __WIFIDECAP__ BrnRadiotapDecap(DEBUG false)

#define PCAP_ENCAP_TYPE 802_11_RADIO
#define PCAP_STRIP_SIZE 0
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


#if WIFITYPE == 807
#ifdef RAWDEV_DEBUG
#define __WIFIENCAP__ OpenBeaconEncap(SRC 13:F3:F3:F3:F3:F3) -> OpenBeaconPrint()
#define __WIFIDECAP__ OpenBeaconPrint() -> OpenBeaconDecap()
#else
#define __WIFIENCAP__ OpenBeaconEncap(SRC 13:F3:F3:F3:F3:F3)
#define __WIFIDECAP__ OpenBeaconDecap()
#endif

#define SOCKETDEVICE
#endif

#undef ns
#undef extra
#undef openbeacon


#ifndef PCAP_ENCAP_TYPE
#define PCAP_ENCAP_TYPE SLL
#endif

#ifndef PCAP_STRIP_SIZE
#define PCAP_STRIP_SIZE 16
#endif

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

#ifdef SOCKETDEVICE

#define FROMRAWDEVICE(x) FromSocket("UDP", 127.0.0.1, 20000)
#define TORAWDEVICE(x) ToSocket("UDP", 127.0.0.1, 20001);

#else

#ifndef NOPCAP

#if PCAP_STRIP_SIZE == 0

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND false, SNIFFER false, METHOD PCAP, ENCAP PCAP_ENCAP_TYPE, HEADROOM 64, BURST PACKETBURST)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD PCAP, DEBUG false, BURST PACKETBURST)

#else

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND false, SNIFFER false, METHOD PCAP, ENCAP PCAP_ENCAP_TYPE, HEADROOM 64, BURST PACKETBURST) -> Strip(PCAP_STRIP_SIZE)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD PCAP, DEBUG false, BURST PACKETBURST)
#endif

#else

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND false, SNIFFER false, METHOD LINUX, HEADROOM 64, BURST PACKETBURST)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD LINUX, DEBUG false, BURST PACKETBURST)

#endif

#endif



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

#define FROMRAWDEVICE(x) FromSimDevice(x, SNAPLEN 8190)
#define TORAWDEVICE(x) ToSimDevice(x, ENCAP UNKNOWN )

#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)
#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__

#define TODUMP ToDump

#define SYNC Null()

#endif
#endif
