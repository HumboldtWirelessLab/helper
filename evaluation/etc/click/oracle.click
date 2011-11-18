FromDump("DUMP" )
	-> raw_cnt :: Counter
	//-> Print("RAW",100)
	-> tee :: Tee;


/********************   WIFI EXTRA   ***********************/
 
tee[0]
	-> wifi_extra_clf :: Classifier(0/01204907,
	                                0/07492001,
	                                -)
	-> wifi_header_cnt_extra :: Counter
	-> Discard;

wifi_extra_clf[1]
	-> wifi_header_cnt_extra;

wifi_extra_clf[2]
	-> Discard;


/********************   ATH2   ****************************/

tee[1]
	-> ath2_brn_clf :: Classifier(32/f3f32510,
	                              32/f3f31025,
	                                -)
	-> wifi_header_cnt_805 :: Counter
	-> Discard;

ath2_brn_clf[1]
	-> wifi_header_cnt_805;

ath2_brn_clf[2]
	-> Discard;


/**********************   ATH   ***************************/

// Idea: check if minimum header length, which is 32 for ath1
tee[2]
	-> chkLen :: CheckLength(31)
	-> Discard;

chkLen[1]
	-> AthdescDecap()
	-> ath_clf :: Classifier(0/08,
	                         0/80,
	                         -)
	-> wifi_header_cnt_804 :: Counter
	-> Discard;

ath_clf[1]
	-> zero_dst::Classifier(4/000000, //802 hat nach AthDecap z.T. auch 08 vorne. Hier wird deshalb nochmal auf invalid dst-mac-address getestet.
	                        - )
	-> Discard;
	
	zero_dst[1]
	-> wifi_header_cnt_804;

ath_clf[2]
	-> Discard;



/*********************   Radiotap   *************************/

tee[3]
	-> RadiotapDecap()
	-> rt_clf :: Classifier(0/08,
	              0/80,
		      -)
	-> wifi_header_cnt_802 :: Counter
	-> Discard;

rt_clf[1]
	-> wifi_header_cnt_802;

rt_clf[2]
	-> Discard;



/**********************   OpenBeacon   ***********************/

// Idea: OpenBeacon-Frames are really small, maximum 14 B for header and 32 for payload
tee[4]
	-> ob_chkLen :: CheckLength(63)[1]
	-> Discard;

ob_chkLen[0]
	-> wifi_header_cnt_806 :: Counter
	-> Discard;


Script(
	wait 0.1,
	read raw_cnt.count,
	read wifi_header_cnt_extra.count,
	read wifi_header_cnt_802.count,
	read wifi_header_cnt_804.count,
	read wifi_header_cnt_805.count,
	read wifi_header_cnt_806.count,
	stop
);


