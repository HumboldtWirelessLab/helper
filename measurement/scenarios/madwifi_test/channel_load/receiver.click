#define DEBUGLEVEL 2

#include "brn/brn.click"
#include "device/rawdev.click"

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

rawdevice::RAWDEV(DEVNAME NODEDEVICE, DEVICE wireless);

rawdevice
  -> __WIFIDECAP__
  -> ate::AirTimeEstimation()
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

Idle
  -> rawdevice;
