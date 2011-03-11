#ifndef __RAWDEV_CLICK__
#define __RAWDEV_CLICK__

elementclass RAWDEV { DEVNAME $devname, DEVICE $device |

  input[0]
#ifdef RAWDEV_DEBUG
  -> Print("To Device")
#endif
//#if WIFITYPE == 802
//  -> Discard();
//#else
  -> TORAWDEVICE($devname);
//#endif

  FROMRAWDEVICE($devname)
#ifdef RAWDEV_DEBUG
  -> Print("From Device")
#endif
#ifdef RAWDUMP
  -> raw_dump_tee :: Tee()
#endif
#ifdef SIMULATION
  -> SetTimestamp()
#endif
  -> BRN2SetDeviceAnno(DEVICE $device)
  -> [0]output;

#ifdef RAWDUMP
   raw_dump_tee[1]
   -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");
#endif

}

#endif
