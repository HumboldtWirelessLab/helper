#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

elementclass WIFIDEV { DEVNAME $devname, DEVICE $device |

#ifdef CST
  cst::ChannelStats(MAX_AGE 100);
#endif

  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);

  input[0]
  -> __WIFIENCAP__
  -> rawdev;

  rawdev
  -> __WIFIDECAP__
#ifdef CST
  -> cst
#endif
  -> [0]output;

}

#endif
