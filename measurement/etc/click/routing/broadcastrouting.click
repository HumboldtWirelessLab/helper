#ifndef __BROADCASTROUTING_CLICK__
#define __BROADCASTROUTING_CLICK__

// input[0] - ethernet (802.3) frames from external nodes (no BRN protocol)
// input[1] - BRN BroadcastRouting packets from internal nodes
// input[2] - failed transmission of a BRN BroadcastRouting  packet (broken link) from ds
// input[3] - passive (overhear)
// input[4] - txfeedback: successful transmission of a BRN BroadcastRouting  packet

// [0]output - ethernet (802.3) frames to external nodes/clients or me (no BRN protocol)
// [1]output - BRN BroadcastRouting packets to internal nodes (BRN BroadcastRouting protocol)
// [2]output - Feedback packets for upper layer

elementclass BROADCASTROUTING {ID $id |

  bcr::BrnBroadcastRouting(NODEIDENTITY $id);

  input[0]
  -> [0]bcr;

  input[1]
  //-> Print("In-BCR-Packet")
  -> BRN2Decap()
  -> [1]bcr;

  bcr[0]
  -> [0]output;

  bcr[1]
  //-> Print("BCR[1]-src-out")
  -> BRN2EtherEncap(USEANNO true)
  -> [1]output;

#ifdef ROUTING_TXFEEDBACK
  Idle -> [2]output;
#endif

}

#endif
