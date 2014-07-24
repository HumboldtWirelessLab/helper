#ifndef __RAWDEV_CLICK__
#define __RAWDEV_CLICK__

/*
 * Input:
 * 0: raw packets
 * 
 * Output:
 * 0: raw rx packets (incl. txfeedback)
 * 1: raw tx packet for further reuse  ; enable this using #define PACKET_REUSE
 *
 */

#ifndef RAWDUMPSNAPLEN
#define RAWDUMPSNAPLEN 8192
#endif

elementclass RAWDEV { DEVNAME $devname, DEVICE $device |

  input[0]
  -> rawdev_suppressor::Suppressor()
#ifdef RAWDEV_DEBUG
  -> SetTimestamp()
  -> Print("NODENAME: To Device", 100, TIMESTAMP true)
#endif
  -> pullstats::PullStats()
#ifdef PACKET_REUSE
#ifdef SIMULATION
  -> simpacketreuse::PullTee()
  -> todev::TORAWDEVICE($devname);

  simpacketreuse[1]
  -> [1]output;
#else
  -> todev::TORAWDEVICE($devname)
  -> [1]output;

  todev[1]
  -> [1]output;
#endif
#else
  -> todev::TORAWDEVICE($devname);
#endif


  fromdev::FROMRAWDEVICE($devname)
#ifdef RAWDEV_DEBUG
  -> SetTimestamp()
  -> Print("NODENAME: From Device", 100, TIMESTAMP true)
#else
#ifdef SIMULATION
  -> SetTimestamp()
#endif
#endif
#ifdef RAWFILTER
  -> RAWFILTER
#endif
#ifdef RAWDUMP
#ifdef REMOTEDUMP
  -> raw_dump_tee::Tee()
#else
#ifdef TMPDUMP
  -> ToDump(FILENAME "/tmp/NODENAME.NODEDEVICE.raw.dump", SNAPLEN RAWDUMPSNAPLEN)
#else
  -> ToDump(FILENAME "RESULTDIR/NODENAME.NODEDEVICE.raw.dump", SNAPLEN RAWDUMPSNAPLEN)
#endif
#endif
#endif
  -> BRN2SetDeviceAnno(DEVICE $device)
  -> [0]output;

#ifdef RAWDUMP
#ifdef REMOTEDUMP
   raw_dump_tee[1]
   -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");
#endif
#endif

}

#endif
