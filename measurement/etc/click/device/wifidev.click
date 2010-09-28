#ifndef __WIFIDEV_CLICK__
#define __WIFIDEV_CLICK__

#include "rawdev.click"

elementclass WIFIDEV { DEVNAME $devname, DEVICE $device |

  rawdev::RAWDEV(DEVNAME $devname, DEVICE $device);
  
  input[0]
  -> __WIFIENCAP__
  -> rawdev;
  
  rawdev
  -> __WIFIDECAP__
  -> [0]output;
  
} 

#endif
