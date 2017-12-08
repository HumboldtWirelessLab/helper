#ifndef __HELPER_INC__
#define __HELPER_INC__

/* NOPCAP (don't use pcap) is default */
/*#ifndef ENABLE_PCAP
#ifndef NOPCAP
#define NOPCAP
#endif
#endif
*/

#ifndef PACKETBURST
#define PACKETBURST 1
#endif

#ifndef DUMPSNAPLEN
#define DUMPSNAPLEN 4000
#endif


#ifndef WIFITYPE
#warning No Wifitype. Using default (805).
#define WIFITYPE 805
#endif

#define wifitype_wifi       801
#define wifitype_prism      802
#define wifitype_radiotap   803
#define wifitype_ath        804
#define wifitype_ath2       805
#define wifitype_extra      806
#define wifitype_openbeacon 807

#if WIFITYPE == wifitype_wifi
#define __WIFIENCAP__ Null()
#define __WIFIDECAP__ Null()
#endif

#if WIFITYPE == wifitype_prism
#define __WIFIENCAP__ Prism2Encap()
#define __WIFIDECAP__ Prism2Decap()
#endif

#if WIFITYPE == wifitype_radiotap
#define __WIFIENCAP__ RadiotapEncap()
#define __WIFIDECAP__ RadiotapDecap(DEBUG false)

#define PCAP_ENCAP_TYPE 802_11_RADIO
#define PCAP_STRIP_SIZE 0
#endif

#if WIFITYPE == wifitype_ath
#define __WIFIENCAP__ AthdescEncap()
#define __WIFIDECAP__ AthdescDecap()
#endif

#if WIFITYPE == wifitype_ath2
#define __WIFIENCAP__ Ath2Encap(ATHENCAP true)

#ifdef CST
#define __WIFIDECAP__ Ath2Decap(ATHDECAP true, CHANNELSTATS CST)
#else
#define __WIFIDECAP__ Ath2Decap(ATHDECAP true)
#endif
#endif

#if WIFITYPE == wifitype_extra
#define __WIFIENCAP__ ExtraEncap()
#define __WIFIDECAP__ ExtraDecap()
#endif

#if WIFITYPE == wifitype_openbeacon
#ifdef RAWDEV_DEBUG
#define __WIFIENCAP__ OpenBeaconEncap(SRC 13:F3:F3:F3:F3:F3) -> OpenBeaconPrint()
#define __WIFIDECAP__ OpenBeaconPrint() -> OpenBeaconDecap()
#else
#define __WIFIENCAP__ OpenBeaconEncap(SRC 13:F3:F3:F3:F3:F3)
#define __WIFIDECAP__ OpenBeaconDecap()
#endif

#define SOCKETDEVICE
#endif

#undef wifitype_ns
#undef wifitype_wifi
#undef wifitype_prism
#undef wifitype_radiotap
#undef wifitype_ath
#undef wifitype_ath2
#undef wifitype_extra
#undef wifitype_openbeacon


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
AddressInfo(ethdev eth0:eth);
AddressInfo(ipdev eth0:ip);
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
/* End KERNEL stuff */


/* USERLEVEL stuff */
#ifdef USERLEVEL

#ifdef SOCKETDEVICE

#define FROMRAWDEVICE(x) FromSocket("UDP", 127.0.0.1, 20000)
#define TORAWDEVICE(x) ToSocket("UDP", 127.0.0.1, 20001);

#else 

#ifdef DUMPDEVICE

#define FROMRAWDEVICE(x) FromDump("DUMPFILESRC", TIMING true)
#define TORAWDEVICE(x) Discard();

#else

#ifndef NOPCAP

#ifndef TODEVICE_METHOD
#define TODEVICE_METHOD LINUX
#endif

#if PCAP_STRIP_SIZE == 0

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND true, SNIFFER false, METHOD PCAP, ENCAP PCAP_ENCAP_TYPE, HEADROOM 64, BURST PACKETBURST)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD TODEVICE_METHOD, DEBUG false, BURST PACKETBURST)
//pcap size
#else

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND true, SNIFFER false, METHOD PCAP, ENCAP PCAP_ENCAP_TYPE, HEADROOM 64, BURST PACKETBURST) -> Strip(PCAP_STRIP_SIZE)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD TODEVICE_METHOD, DEBUG false, BURST PACKETBURST)
//end pcap size
#endif
//nopcap
#else

#define FROMRAWDEVICE(x) FromDevice(DEVNAME x, PROMISC true, SNAPLEN 8190, OUTBOUND true, SNIFFER false, METHOD LINUX, HEADROOM 64, BURST PACKETBURST)
#define TORAWDEVICE(x) ToDevice(DEVNAME x, METHOD LINUX, DEBUG false, BURST PACKETBURST)
//end no pcap
#endif

//else for dumpdevice
#endif
//else for socketdevice
#endif

#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__
#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)

#ifdef REMOTEDUMP
AddressInfo(ethdev eth0:eth);
AddressInfo(ipdev eth0:ip);

#define DUMPPORTBASE DUMPPORT@__LINE__
#define TODUMP(x) TimestampEncap() \
                  -> Socket(UDP, DUMPIP, DUMPPORTBASE, CLIENT true ) \
                  -> Discard
#else
#define TODUMP(x) ToDump(FILENAME x, SNAPLEN DUMPSNAPLEN)
#endif


#define SYNC Idle \
              ->Socket(UDP,0.0.0.0,60000) \
              ->Print("Sync",TIMESTAMP true)

#endif


/* SIMULATION stuff */

#ifdef SIMULATION

#ifdef DUMPDEVICE

#define FROMRAWDEVICE(x) FromDump(FILENAME DUMPFILESRC, TIMING true)
#define TORAWDEVICE(x) Discard()

#else

#ifdef USED_SIMULATOR_JIST
#define FROMRAWDEVICE(x) FromSimDevice(x, SNAPLEN 8190, HEADROOM 192, ZEROCOPY false)
#else
#define FROMRAWDEVICE(x) FromSimDevice(x, SNAPLEN 8190, HEADROOM 192, ZEROCOPY true)
#endif

#ifdef POLLING
#define TORAWDEVICE(x) ToSimDevice(x, ENCAP UNKNOWN )
#else
#define TORAWDEVICE(x) ToSimDevice(x, ENCAP UNKNOWN, POLLING false, HAVETXFEEDBACKANNO true )
#endif

#endif

#define TODEVICE(x) __WIFIENCAP__ -> TORAWDEVICE(x)
#define FROMDEVICE(x) FROMRAWDEVICE(x) -> __WIFIDECAP__

#define TODUMP(x) ToDump(FILENAME x, SNAPLEN DUMPSNAPLEN)

#define SYNC Null()

#endif
#endif
