#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

elementclass WIFIDEV { DEVNAME $devname, DEVICE $device |

#ifdef CST
#ifdef CST_PROCFILE
  cst::ChannelStats(MAX_AGE 100, PROCFILE CST_PROCFILE, PROCINTERVAL 100);
#else
  cst::ChannelStats(MAX_AGE 100);
#endif
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
