#ifndef __RAWDEV_CLICK__
#define __RAWDEV_CLICK__

elementclass RAWDEV { DEVNAME $devname, DEVICE $device |

  input[0]
//-> Print("To Device")
  -> TORAWDEVICE($devname);

  FROMRAWDEVICE($devname)
//-> Print("From Device")
  -> BRN2SetDeviceAnno(DEVICE $device)
  -> [0]output;
}

#endif
