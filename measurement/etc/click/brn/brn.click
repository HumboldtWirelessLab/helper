#ifndef BRN_CLICK
#define BRN_CLICK

#ifndef DEBUGLEVEL
#define DEBUGLEVEL 2
#endif


#define BRN_ETHERTYPE                 8086
#define BRN_ETHERTYPE_HEX             0x8086


/*Basics and Services*/
#define BRN_PORT_LINK_PROBE           01
#define BRN_PORT_IAPP                 02
#define BRN_PORT_GATEWAY              03
#define BRN_PORT_EVENTHANDLER         04
#define BRN_PORT_ALARMINGPROTOCOL     05
/*Routing*/
#define BRN_PORT_DSR                  0a
#define BRN_PORT_BCASTROUTING         0b
#define BRN_PORT_FLOODING             0c
#define BRN_PORT_BATMAN               0d
#define BRN_PORT_GEOROUTING           0e
#define BRN_PORT_DART                 0f
#define BRN_PORT_HAWK                 10
#define BRN_PORT_OLSR                 11
#define BRN_PORT_AODV                 12
/*Clustering*/
#define BRN_PORT_DCLUSTER             1e
#define BRN_PORT_NHOPCLUSTER          1f
/*Topology*/
#define BRN_PORT_TOPOLOGY_DETECTION   23
#define BRN_PORT_NHOPNEIGHBOURING     24
/*P2P*/
#define BRN_PORT_DHTROUTING           28
#define BRN_PORT_DHTSTORAGE           29
/*Data transfer*/
#define BRN_PORT_SDP                  32
#define BRN_PORT_TFTP                 33
#define BRN_PORT_FLOW                 34
#define BRN_PORT_COMPRESSION          35

#endif
