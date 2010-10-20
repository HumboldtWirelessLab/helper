#define DEBUGLEVEL 2
#define ATE ate

#include "brn/helper.inc"
#include "brn/brn.click"
#include "device/rawdev.click"

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

rawdevice::RAWDEV(DEVNAME NODEDEVICE, DEVICE wireless);

ate::AirTimeEstimation(MAX_AGE 1000);

rawdevice
  -> __WIFIDECAP__
  -> ate
  -> Discard;
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

Idle
  -> rawdevice;
