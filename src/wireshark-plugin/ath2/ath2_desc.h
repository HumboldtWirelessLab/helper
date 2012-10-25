#ifndef ATH2DESC

#define ATH2DESC

#define ATHDESC_HEADER_SIZE 32
struct ar5212_rx_status {
	u_int32_t data_len:12;
	u_int32_t more:1;
	u_int32_t decomperr:2;
	u_int32_t rx_rate:5;
	u_int32_t rx_rssi:8;
	u_int32_t rx_ant:4;


	u_int32_t done:1;
	u_int32_t rx_ok:1;
	u_int32_t crcerr:1;
	u_int32_t decryptcrc:1;
} __attribute__ ((packed));

struct ar5212_desc {
	/*
	 * tx_control_0
	 */
	u_int32_t	frame_len:12;
	u_int32_t	reserved_12_15:4;
	u_int32_t	xmit_power:6;
	u_int32_t	rts_cts_enable:1;
	u_int32_t	veol:1;
	u_int32_t	clear_dest_mask:1;
	u_int32_t	ant_mode_xmit:4;
	u_int32_t	inter_req:1;
	u_int32_t	encrypt_key_valid:1;
	u_int32_t	cts_enable:1;

	/*
	 * tx_control_1
	 */
	u_int32_t	buf_len:12;
	u_int32_t	more:1;
	u_int32_t	encrypt_key_index:7;
	u_int32_t	frame_type:4;
	u_int32_t	no_ack:1;
	u_int32_t	comp_proc:2;
	u_int32_t	comp_iv_len:2;
	u_int32_t	comp_icv_len:2;
	u_int32_t	reserved_31:1;

	/*
	 * tx_control_2
	 */
	u_int32_t	rts_duration:15;
	u_int32_t	duration_update_enable:1;
	u_int32_t	xmit_tries0:4;
	u_int32_t	xmit_tries1:4;
	u_int32_t	xmit_tries2:4;
	u_int32_t	xmit_tries3:4;

	/*
	 * tx_control_3
	 */
	u_int32_t	xmit_rate0:5;
	u_int32_t	xmit_rate1:5;
	u_int32_t	xmit_rate2:5;
	u_int32_t	xmit_rate3:5;
	u_int32_t	rts_cts_rate:5;
	u_int32_t	reserved_25_31:7;

	/*
	 * tx_status_0
	 */
	u_int32_t	frame_xmit_ok:1;
	u_int32_t	excessive_retries:1;
	u_int32_t	fifo_underrun:1;
	u_int32_t	filtered:1;
	u_int32_t	rts_fail_count:4;
	u_int32_t	data_fail_count:4;
	u_int32_t	virt_coll_count:4;
	u_int32_t	send_timestamp:16;

	/*
	 * tx_status_1
	 */
	u_int32_t	done:1;
	u_int32_t	seq_num:12;
	u_int32_t	ack_sig_strength:8;
	u_int32_t	final_ts_index:2;
	u_int32_t	comp_success:1;
	u_int32_t	xmit_antenna:1;
	u_int32_t	reserved_25_31_x:7;
}  __attribute__ ((packed));
/*
inline int 
ratecode_to_dot11(int ratecode) {
	switch (ratecode) {
		/* a */
/*	case 11: return 12;  
	case 15: return 18;  
	case 10: return 24;  
	case 14: return 36;  
	case 9: return 48;  
	case 13: return 72;  
	case 8: return 96;  
	case 12: return 108; 
		
	case 0x1b: return 2;   
	case 0x1a: return 4;   
	case 0x1e: return 4;   
	case 0x19: return 11;  
	case 0x1d: return 11;  
	case 0x18: return 22;  
	case 0x1c: return 22;  
	}
	return 0;
}

inline int 
dot11_to_ratecode(int dot11) {
	switch (dot11) {
	  case 12:  return 11; 
	  case 18:  return 15; 
	  case 24:  return 10; 
	  case 36:  return 14; 
	  case 48:  return 9; 
	  case 72:  return 13; 
	  case 96:  return 8; 
	  case 108: return 12;

	  case 2:   return 0x1b; 
	  case 4:   return 0x1e; 
	  case 11:  return 0x1d; 
	  case 22:  return 0x1c; 
	}
	return 0;
}
*/

struct ath2_rx_status {
    u_int16_t	rs_datalen; /* rx frame length */
    u_int8_t	rs_status;  /* rx status, 0 => recv ok */
    u_int8_t	rs_phyerr;  /* phy error code */

    int8_t	rs_rssi;    /* rx frame RSSI (combined for 11n) */
    u_int8_t	rs_keyix;   /* key cache index */
    u_int8_t	rs_rate;    /* h/w receive rate index */
    u_int8_t	rs_more;    /* more descriptors follow */

    u_int32_t	rs_tstamp;  /* h/w assigned timestamp */
    u_int32_t	rs_antenna; /* antenna information */

    u_int64_t	rs_hosttime;
    u_int64_t	rs_mactime;

    int8_t	rs_noise;
    int8_t	reserved[3];

} __attribute__ ((packed));

struct ath2_tx_status {
    u_int16_t	ts_seqnum;    /* h/w assigned sequence number */
    u_int16_t	ts_tstamp;    /* h/w assigned timestamp */

    u_int8_t	ts_status;    /* frame status, 0 => xmit ok */
    u_int8_t	ts_rate;      /* h/w transmit rate index */
    int8_t	ts_rssi;      /* tx ack RSSI */
    u_int8_t	ts_shortretry;/* # short retries */

    u_int8_t	ts_longretry; /* # long retries */
    u_int8_t	ts_virtcol;   /* virtual collision count */
    u_int8_t	ts_antenna;   /* antenna information */
    u_int8_t	ts_finaltsi;  /* final transmit series index */

    u_int64_t	ts_hosttime;
    u_int64_t	ts_mactime;

    int8_t	ts_noise;
    int8_t	reserved[3];

} __attribute__ ((packed));

struct ath2_tx_anno {

    int8_t operation;       //we use packets to configure the mac

    int8_t channel;         //channel to set

    u_int8_t mac[6];        //mac address use for sending or set as client for VA

    u_int8_t va_position;   //position in VA

} __attribute__ ((packed));

struct ath2_rx_anno {

  int8_t operation;       //we use packets to configure the mac

  int8_t channel;         //channel to set

  u_int8_t mac[6];        //mac address use for sending or set as client for VA

  u_int8_t va_position;   //position in VA

  u_int8_t status;

} __attribute__ ((packed));

struct ath2_header {
    u_int16_t ath2_version;
    u_int16_t madwifi_version;

    u_int32_t flags;

    union {
      struct ath2_rx_status rx;             //info of received packets
      struct ath2_tx_status tx;             //inof of txfeedbackpackets
      struct ath2_tx_anno tx_anno;          //annos of send packets
      struct ath2_rx_anno rx_anno;          //annos of operation packets (result)
    } anno;

} __attribute__ ((packed));

#define ATHDESC2_VERSION 0xF3F3

#define MADWIFI_0940	0x03ac
#define MADWIFI_3869	0x0f1d
#define MADWIFI_3880  0x0f28

#define MADWIFI_TRUNK MADWIFI_3880

#define ATH2_OPERATION_NONE        0
#define ATH2_OPERATION_SETVACLIENT 1
#define ATH2_OPERATION_SETCHANNEL  2
#define ATH2_OPERATION_SETMAC      3

#ifndef ARPHRD_IEEE80211_ATHDESC2
#define ARPHRD_IEEE80211_ATHDESC2  805 /* IEEE 802.11 + atheros (long) descriptor */
#endif /* ARPHRD_IEEE80211_ATHDESC2 */

#define ATHDESC2_BRN_HEADER_SIZE sizeof(struct ath2_header)
#define ATHDESC2_HEADER_SIZE    ( ATHDESC_HEADER_SIZE + ATHDESC2_BRN_HEADER_SIZE )
#endif
