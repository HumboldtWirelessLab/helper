#ifndef __RAWDEV_CLICK__
#define __RAWDEV_CLICK__


#ifndef RAWDUMPSNAPLEN
#define RAWDUMPSNAPLEN 8192
#endif

elementclass RAWDEV { DEVNAME $devname, DEVICE $device |

  input[0]
#ifdef RAWDEV_DEBUG
  -> Print("To Device")
#endif
#ifdef PACKET_REUSE
  -> toraw::TORAWDEVICE($devname)
  -> [1]output;

  toraw[1]
  -> [1]output;
#else
  -> TORAWDEVICE($devname);
#endif

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
   -> TODUMP(FILENAME "RESULTDIR/NODENAME.NODEDEVICE.raw.dump", SNAPLEN RAWDUMPSNAPLEN);
#endif

}

#endif
