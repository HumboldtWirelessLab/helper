elementclass WIFIFILTER {
  input[0]
  -> wifierr_clf::WifiErrorClassifier()
  -> minl :: CheckLength(9)[1]
  -> ctl_size_clf :: CheckLength(10)
  //control frames
  //-> Print("CTL")
  -> ctl_clf :: Classifier(0/d4,  //ack 
                           0/c4,  //cts
                           -);

  ctl_clf[0] -> [0]output;
  ctl_clf[1] -> [0]output;
  ctl_clf[2] -> [1]output;


  ctl_size_clf[1] //rts
  -> minl_2 :: CheckLength(15)[1]
  -> ctl_rts_size_clf :: CheckLength(16)
  -> rts_clf :: Classifier(0/b4,  //rts 
                           -);

  rts_clf[0] -> [0]output;
  rts_clf[1] -> [1]output;

  ctl_rts_size_clf[1] //data/mngt?
  -> data_clf :: Classifier(0/08,
                            0/80,
                            0/88, //tods
                            0/48, //tods
                            0/c8, //tods
                            0/40, //mgmt probe_req
                            0/50, //mgmt probe_resp
                             -);

  data_clf[0] -> [0]output;
  data_clf[1] -> [0]output;
  data_clf[2] -> [0]output;
  data_clf[3] -> [0]output;
  data_clf[4] -> [0]output;
  data_clf[5] -> [0]output;
  data_clf[6] -> [0]output;
  data_clf[7] -> [1]output;


  minl[0]   -> [1]output; //too small
  minl_2[0] -> [1]output; //too small
  wifierr_clf[1] -> [1]output; //error

}

//FromDump("DUMP", STOP true)
FromDump("DUMP")
	-> raw_cnt :: Counter
	//-> Print("RAW",100)
//COMPRESSION -> pdc::PacketDecompression(CMODE 0)
//COMPRESSION -> n::Null();
//COMPRESSION pdc[1]
//COMPRESSION -> n
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
	-> ath_clf :: WIFIFILTER()
	-> zeros_clf::Classifier(02/00000000,-)
	-> Discard;

zeros_clf[1]
	-> wifi_header_cnt_804 :: Counter
	-> Discard;

ath_clf[1]
	-> Discard;


/*********************   Radiotap   *************************/
tee[3]
	-> BrnRadiotapDecap()
	-> brnradiotap_filter::WIFIFILTER()
	-> wifi_header_cnt_803 :: Counter
	-> Discard;

brnradiotap_filter[1]
	-> Discard;


/**********************   Compressed  ***********************/

// Idea: Compressed have 9f in the beginning
tee[4]
	-> comp_clf :: Classifier(0/9f,
		                 -)
	-> wifi_header_cnt_compressed :: Counter
	-> Discard;

comp_clf[1]
	-> Discard;

/**********************   OpenBeacon   ***********************/

// Idea: OpenBeacon-Frames are really small, maximum 14 B for header and 32 for payload
// TODO: check for real length
tee[5]
	-> ob_chkLen :: CheckLength(46)[1]
	-> Discard;

ob_chkLen[0]
	-> wifi_header_cnt_806 :: Counter
	-> Discard;
	

/*********************   Wifi   *************************/

tee[6]
	-> wifi_clf::WIFIFILTER()
	-> wifi_header_cnt_801 :: Counter
	-> Discard;

wifi_clf[1]
	-> Discard;

/*********************   Prism2   *************************/
tee[7]
	-> Prism2Decap()
	-> prism_clf :: WIFIFILTER()
	-> wifi_header_cnt_802 :: Counter
	-> Discard;

prism_clf[1]
	-> Discard;


/*************   NON (dummy for paring results)  ************/

Idle()
-> wifi_header_cnt_non :: Counter
-> Discard;

Script(
	wait 0.1,
	read raw_cnt.count,
	read wifi_header_cnt_extra.count,
	read wifi_header_cnt_801.count,
	read wifi_header_cnt_802.count,
	read wifi_header_cnt_803.count,
	read wifi_header_cnt_804.count,
	read wifi_header_cnt_805.count,
	read wifi_header_cnt_compressed.count,
	read wifi_header_cnt_806.count,
	read wifi_header_cnt_non.count,
	stop
);
