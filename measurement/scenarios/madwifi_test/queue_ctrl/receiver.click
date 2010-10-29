#define DEBUGLEVEL 2
#define CST cst

#include "brn/helper.inc"
#include "brn/brn.click"
#include "device/rawdev.click"

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

rawdevice::RAWDEV(DEVNAME NODEDEVICE, DEVICE wireless);

cst::ChannelStats(MAX_AGE 100);

rawdevice
  -> t::Tee()
  -> __WIFIDECAP__
  -> cst
  -> Discard;

  t[1]
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

Idle
  -> rawdevice;
