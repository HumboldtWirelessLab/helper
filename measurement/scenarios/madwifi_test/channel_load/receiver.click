#define DEBUGLEVEL 2
#define CST cst

#include "brn/helper.inc"
#include "brn/brn.click"
#include "device/rawdev.click"

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

rawdevice::RAWDEV(DEVNAME NODEDEVICE, DEVICE wireless);

//cst::ChannelStats(MAX_AGE 100);
cst::ChannelStats(STATS_DURATION 1000, SAVE_DURATION 1000, RSSI_PER_NEIGHBOUR true, STATS_TIMER true, FAST_MODE true);

rawdevice
//  -> t::Tee()
  -> __WIFIDECAP__
  -> cst
  -> Discard;

//  t[1]
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

Idle
  -> rawdevice;
