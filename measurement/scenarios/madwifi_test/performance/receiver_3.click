
#define CST cst

#include "brn/helper.inc"
#include "brn/brn.click"
#include "device/wifidev.click"

BRNAddressInfo(deviceaddress NODEDEVICE:eth);
wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS deviceaddress, DEVICETYPE "WIRELESS");

wifidev::WIFIDEV(DEVNAME "NODEDEVICE", DEVICE wireless);

Idle
  -> wifidev
  -> ct::Counter()
  -> Discard;

Script(
  wait 55,
  read ct.count,
  read ct.byte_count
);
