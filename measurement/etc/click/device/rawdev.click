#ifndef __RAWDEV_CLICK__
#define __RAWDEV_CLICK__

elementclass RAWDEV { DEVNAME $devname, DEVICE $device |

  input[0]
#ifdef RAWDEV_DEBUG
  -> Print("To Device")
#endif
  -> TORAWDEVICE($devname);

  FROMRAWDEVICE($devname)
#ifdef RAWDEV_DEBUG
  -> Print("From Device")
#endif
#ifdef SIMULATION
  -> SetTimestamp()
#endif
  -> BRN2SetDeviceAnno(DEVICE $device)
  -> [0]output;
}

#endif
