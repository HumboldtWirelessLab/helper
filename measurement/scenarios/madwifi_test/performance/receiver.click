#include "brn/helper.inc"
#include "brn/brn.click"
#include "device/rawdev.click"

FROMRAWDEVICE(NODEDEVICE)
  -> ct::Counter()
  -> Discard;

Script(
  wait 55,
  read ct.count,
  read ct.byte_count
);
