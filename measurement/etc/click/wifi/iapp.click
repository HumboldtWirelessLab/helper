/* Copyright (C) 2005 BerlinRoofNet Lab
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA. 
 *
 * For additional licensing options, consult http://www.BerlinRoofNet.de 
 * or contact brn@informatik.hu-berlin.de. 
 */

/*
 * inter-ap protocol configuration in click
 */

/* Parameter:
 * ==========
 * - ID                := node $identity
 * - LINKTABLE         := link table
 * - ASSOCLIST         := list of associated stations
 
 * =====================
 *  - input[0]        <- 802.11 frames from the queue to the interface ( q -> )
 *  - output[0]       -> 802.11 frames to the interface ( -> ToDevice)
 *
 *  - input[1]        <- BRN_IAPP packets (destinating, without further header)
 *                       (brn_clf[6] -> Strip(6) -> )
 *  - input[2]        <- BRN_IAPP packets (peeked, without further header)
 *  - input[3]        <- 802.3 frames which could not be forwarded 
 *                         (dsr[2] -> Strip(182) -> ) failure from dsr 
 *                         (FilterFailures[1] -> WifiDecap -> ) from dev no ack
 *  - input[4]        <- 802.11 infrastructure data with foreign BSSID
                            (filter_bssid[1] -> )
 *  - output[1]       -> 802.3 frames to be routed ( -> [0]dsr)
 *  - output[2]       -> ????
 *
 *  - output[3]       -> BRN_IAPP notify packets with further information
                         for other elements (Gateway needs to know about hand overs)
 */

elementclass IAPP {
  STALE $stale,
  ASSOCLIST $assoc_list,
  ASSOC_RESP $assoc_resp,
  NODEIDENTITY $id,
  LINKTABLE $lt,
  // SIG_ASSOC $sig_assoc
  |

  iapp_encap  :: BrnIappEncap();

  iapp_filter :: BrnIappRoamingFilter(ASSOCLIST $assoc_list);

  sta_tracker :: BrnIappStationTracker(
                  NODEIDENTITY $id,
                  LINKTABLE $lt,
                  STALE $stale,
                  ASSOCLIST $assoc_list,
                  NOTIFYHDL notify_hdl,
                  DATAHDL data_hdl,
                  ASSOC_RESP $assoc_resp);
                  //SIG_ASSOC $sig_assoc);

  hello_hdl   :: BrnIappHelloHandler(
                  NODEIDENTITY $id,
                  LINKTABLE $lt,
                  ASSOCLIST $assoc_list,
                  ENCAP iapp_encap,
                  STALE $stale);

  notify_hdl  :: BrnIappNotifyHandler(
                  NODEIDENTITY $id,
                  RESEND_NOTIFY 100, 
                  NUM_RESEND 7, 
                  ASSOCLIST $assoc_list, 
                  ENCAP iapp_encap, 
                  STATRACK sta_tracker,
                  );

  route_hdl   :: BrnIappRouteUpdateHandler(
                  NODEIDENTITY $id,
                  LINKTABLE $lt,
                  ASSOCLIST $assoc_list,
                  ENCAP iapp_encap,
                  HELLOHDL hello_hdl);

  data_hdl    :: BrnIappDataHandler(
                  NODEIDENTITY $id,
                  ASSOCLIST $assoc_list, 
                  ENCAP iapp_encap, 
                  ROUTEHDL route_hdl);

  snoopy      :: BrnIappStationSnooper(
                  NODEIDENTITY $id,
                  ASSOCLIST $assoc_list, 
                  STATRACK sta_tracker, 
                  HELLOHDL hello_hdl);

  all :: BrnCompoundHandler(CLASSES "BrnIappEncap BrnIappRoamingFilter BrnIappStationTracker BrnIappHelloHandler BrnIappRouteUpdateHandler BrnIappDataHandler BrnIappStationSnooper", CLASSESHANDLER "debug", CLASSESVALUE "2");

  optimize :: BrnCompoundHandler(CLASSES "BrnIappStationSnooper BrnIappHelloHandler BrnIappDataHandler BrnIappStationTracker", CLASSESHANDLER "optimize", CLASSESVALUE "true");

  //----------------------------------------------------------------------------
  // Look into all packets from the queue and filter out those to roamed STAs.
  // If such a packet is found, it is duplicated and given to the iapp and
  // to the dsr error forwarder in order to generate a route errror, which
  // is send to the originator of the packet.

  elementclass ip_printer {  
    input[0]
    -> ethertype_clf :: Classifier(12/8086, 12/0800);

    ethertype_clf[0] // brn
    -> CheckIPHeader(OFFSET 58)
    //-> IPPrint("from_iapp_data_to_dsr0")
    -> [0]output;

    ethertype_clf[1] // ether
    -> CheckIPHeader(OFFSET 14)
    //-> IPPrint("from_iapp_data_to_dsr0")
    -> [0]output;
  }

  data2_hdl   :: BrnIappDataHandler(
                  NODEIDENTITY $id,
                  ASSOCLIST $assoc_list, 
                  ENCAP iapp_encap, 
                  ROUTEHDL route_hdl);

  Idle()
    -> data2_hdl;

  input[0]
    -> iapp_filter
    -> [0]output;
  
  iapp_filter[1]
    -> WifiDecap()
    //-> Print("from_filter_to_iapp")
    -> [1]data2_hdl;
  
  data2_hdl[0]
    -> SetPacketAnno(TOS 1)
    //-> Print("from_iapp_data2_to_dsr0")
    -> ip_printer // TODO remove
    -> [1]output;

  //----------------------------------------------------------------------------
  // Handle incoming IAPP packets
  
  input[1]
    //-> Print("from_input_to_iapp")
    -> iapp_clf :: Classifier(0/01, // notify
                              0/02, // reply
                              0/03, // data
                              0/04, // route update
                              0/05, // hello
                              - );
  
  iapp_clf[0] // notify
    -> [0]notify_hdl;

  iapp_clf[1] // reply
    -> [1]notify_hdl;

  iapp_clf[2] // data
    -> [0]data_hdl;

  iapp_clf[3] // route update
    -> [0]route_hdl;

  iapp_clf[4] // hello
    -> [0]hello_hdl;

  iapp_clf[5] // other
    -> Print("BOGUS --- invalid brn iapp type")
    -> Discard();

  //----------------------------------------------------------------------------
  // Handle iapp peeks
  
  input[2]
    //-> Print("from_peek_to_iapp")
    -> [0]sta_tracker;

  //----------------------------------------------------------------------------
  // Handle Ethernet frames which could not be forwarded (STA roamed?)

  input[3]
    //-> Print("from_failure_to_iapp")
    -> [1]data_hdl;

  //----------------------------------------------------------------------------
  // Handle Wifi with foreign BSSID 

  input[4]
    //-> PrintWifi("from_host_filter_to_iapp")
    //-> Print("from_host_filter_to_iapp")
    -> [0]snoopy;

  //----------------------------------------------------------------------------
  // Either IAPP packets encapsulated in BRN/Ethernet to be routet to other 
  // mesh nodes or packets for roamed STAs, which are sent to the new mesh node.

  notify_hdl[0]
  //-> Print("from_iapp_notify_to_dsr0")
  -> SetPacketAnno(TOS 1)
  -> [1]output;

  notify_hdl[1]
  -> [3]output;

  data_hdl[0]
  //-> Print("from_iapp_data_to_dsr0")
    -> ip_printer // TODO remove
    -> [1]output;

  route_hdl[0]
  //-> Print("from_iapp_route_to_dsr0")
  -> SetPacketAnno(TOS 1)
  -> [1]output;

  hello_hdl[0]
  //-> Print("from_iapp_hello_to_dsr0")
  -> [1]output;

  data2_hdl[1]
  -> [2]output;

  data_hdl[1]
  -> [2]output;
}

elementclass IAPP_Peek {

  input 
    -> dsr_src_clf :: Classifier(0/BRN_PORT_DSR 6/04, -)
    -> BRN2Decap()
    //-> StripDSRHeader()
         -> iapp_peek :: Classifier(12/8086 14/BRN_PORT_IAPP, -)
         -> iapp_peek_tee :: Tee() // Duplicate because it is killed in iapp
         -> BRN2EtherDecap() // strips an ethernet header
         -> BRN2Decap()
         -> [1]output;

  dsr_src_clf[1]
       -> [0]output;

  iapp_peek[1]
    -> PushPacketHeader()
    -> [0]output;

  iapp_peek_tee[1]
    -> PushPacketHeader()
    -> [0]output;
}
