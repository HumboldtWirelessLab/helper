#!/usr/bin/awk -f 

# Usage:  cat dumpfile | awk -vPREFIX=ath0 -f genMatlabFile.awk
# 
# This script generates 3 files:
# PREFIX.ssid.idx			: contains all ssid and their integer representation
# PREFIX.stringmap.idx		: contains all string values used and their integer representation
# PREFIX.data.dat			: contains all the data formated to integer values
# PREFIX.ignoredlines.log	: contains ignored lines like TX, ATHOPERATION or faulty formats.
#
# PREFIX is a variable set from the outside to distinguish between different dumps.
#
# The script ignores the following outputs:
# 	Packets with the label "ATHOPERATION:", "PHY_TO_SHORTerror:", "ZeroRateError", as well as "DumpError:"
# 	also all "(TX)" printouts
# Every ignored line can be found in PREFIX.ignoredlines.log.
#
# In case of unkown types and subtypes the click printout would be:
#	unknown-types-[:digit:]+ 
#	unknown-subtype-[:digit:]+ 
# In those cases type and subtype will carry the digit negative number -[:digit:], where digit comes from the 
# click printout.
#
# Plot vergleich:
#	IBSS zusammengelegt, data packets mit nods und beacons mit IBSS capability 
#   Mean RX Power scheint nicht ganz überein zu stimmen? 
#	Retry-Ratio: Fehler beim neuen, korriegiert
#	Sonst alles gleich.


BEGIN { 
	# data initiation:
	# Here we set the strings and their integer mappings. 
	# Also it sets the output files according to the extern variable PREFIX.

	used["notFound"] = -1;# no ssid tag was found within the packet info
	used["(none)"] = -2;
	used["(invalid_ssid)"] = -3;
	used["(empty)"] = -4;
	used[""] = -5;# the ssid was not found (might have been one or more whitespaces), but we saw a ssid: tag
	usedSize = 5; # bug workaround, length() doesn't work for array in some unstable older versions of awk



	if ( PREFIX == "" ) { PREFIX = "awk"; }
	ignoredLinesLog = PREFIX".ignoredlines.log";
	dataDat = PREFIX".data.dat";
	StringMap = PREFIX".stringmap.idx";	
	SSIDMap = PREFIX".ssid.idx";

	# -Inf is used for severe errors. Like unexpected content.
	PhyerrStrMap["PyherrStrERROR"] = "-Inf";
	PhyerrStrMap["(HAL_PHYERR_CCK_RESTART)"] = 1;
	PhyerrStrMap["(HAL_PHYERR_OFDM_RESTART)"] = 2;
	PhyerrStrMap["(HAL_PHYERR_TOR)"] = 3;
	PhyerrStrMap["(none)"] = 4;

	PacketLabelMap["PacketLabelERROR"] = "-Inf";
	PacketLabelMap["ATHOPERATION:"] = 1;
	PacketLabelMap["CRCerror:"] = 2;
	PacketLabelMap["CRC_TO_LONGerror:"] = 3;
	PacketLabelMap["OKPacket:"] = 4;
	PacketLabelMap["PHYerror:"] = 5;
	PacketLabelMap["PHY_TO_SHORTerror:"] = 6;
	PacketLabelMap["PHY_TO_LONGerror:"] = 7;
	PacketLabelMap["ZeroRateError:"] = 8;
	
	FrameTypeMap["FrameTypeERROR"] = "-Inf";
	FrameTypeMap["mgmt"] = 1;
	FrameTypeMap["cntl"] = 2;
	FrameTypeMap["data"] = 3;
	# more unkown Frame types get added while processing
	# so the *.idx file is being created within the END{ awk statement.
	
	FrameSubTypeMap["FrameSubTypeERROR"] = "-Inf";
	FrameSubTypeMap["psp"] = 1;
	FrameSubTypeMap["rts"] = 2;
	FrameSubTypeMap["cts"] = 3;
	FrameSubTypeMap["ack"] = 4;
	FrameSubTypeMap["cfe"] = 5;
	FrameSubTypeMap["cfea"] = 6;
	FrameSubTypeMap["nods"] = 7;
	FrameSubTypeMap["tods"] = 8;
	FrameSubTypeMap["frds"] = 9;
	FrameSubTypeMap["dsds"] = 10;
	FrameSubTypeMap["reassoc_req"] = 11;
	FrameSubTypeMap["reassoc_resp"] = 12;
	FrameSubTypeMap["assoc_req"] = 13;
	FrameSubTypeMap["assoc_resp"] = 14;
	FrameSubTypeMap["probe_req"] = 15;
	FrameSubTypeMap["probe_resp"] = 16;
	FrameSubTypeMap["disassoc"] = 17;
	FrameSubTypeMap["beacon"] = 18;
	FrameSubTypeMap["deauth"] = 19;
	FrameSubTypeMap["auth"] = 20;
	FrameSubTypeMap["atim"] = 21;
	# more unknown-subtype Frame types get added while processing
	# so the *.idx file is being created within the END{ awk statement.
	
	# empty the files
	print "\tCreated " PREFIX".ignoredlines.log";
	printf "" > ignoredLinesLog;
	
	print "\tCreated " PREFIX".stringmap.idx ";
	printf "" > StringMap;
	
	print "\tCreated " PREFIX".data.dat ";
	printf "" > dataDat;
	
	print "\tCreated " PREFIX".ssid.idx ";
	printf "" > SSIDMap;
	
	for ( PacketLabel in PacketLabelMap ){
		print PacketLabel "\t" PacketLabelMap[PacketLabel] >> StringMap;
	}
	
	# contains the phyerrstr as well as the integer representation	
	for (PhyErrStr in PhyerrStrMap ){
		print PhyErrStr "\t"  PhyerrStrMap[PhyErrStr] >> StringMap;
	}
	
	# dataDat header: WARNING if you change the header you must change the printout for the
	# values accordingly so that the columnheaders match the values
	# Also: the matlab scripts use these headers to access the data. This means if you change 
	# 		the headers here you must change them inside the matlab scripts as well.
	# On the other hand, changing the position will have no effect on the matlab script as 
	# long as the column headers match the values within the columns.
	printf "lat\tlong\talt\tspeed\tath\tstatus\trate\trssi\tlen\tmore\tDCerr" >> dataDat; 
	printf  "\tant\tdone\tCRCerr\tdecryptCRC\tSEClen\tts\tSECstatus\tSECrate\tSECrssi" >> dataDat;
	printf  "\tSECant\tnoise\thosttime\tmactime\tchannel\tchannelUtil\tdriverFlags\tFlags\tphyErr\tphyErrStr" >> dataDat;
	printf  "\tSECmore\tkeyix\tpacketLabelnum\ttime\tsizebytes" >> dataDat; 
	printf "\tTHRDRate\tTHRDrssi\tTHRDnoise\tFrameType\tFrameSubType\tAddr1\tAddr2\tAddr3\tpacketChan" >> dataDat;
	printf "\tssidInt\tseq\tIBSS\tESS\tPRIVACY\tCF_POLLABLE\tCF_POLLREQ\tRetry" >> dataDat; 
	printf "\n" >> dataDat;
	
	print "\tAWK-Script: processing.. "
}


{
	printf  "\x0d" "\tline: " FNR; 

	# minimum of 72 entries needed, sometimes lower entries(fault) occur
	if ( check(16, "Not enough entries") == 0 ){
		next;
	}
	
	lat = $2; long = $4; alt = $6; speed = $8;

	# ATH :(RX) = receive frame -> 0, (TX) = receive frame -> 1
	if ( $10 == "(RX)" ) {
		ath = 0;
	# ignore tx printouts
	} else if ( $10 == "(TX)" ){
		ath = 1;
		ignoreLine("(TX)");next;
	# ingore dumperrors
	} else if ( $9 == "DumpError:" ) {
		ignoreLine("DumpError");
		next;
	}
	

	status=$12; rate=$15; rssi=$17; len=$19; more=$21; DCerr=$23; ant=$25; done=$27; CRCerr=$29; decryptCRC=$31; 
	SEClen=$34; ts=$36; SECstatus=$38; SECrate=$41; SECrssi=$43; SECant=$45;noise=$47;hosttime=$49;mactime=$51; 
	channel=$53; channelUtil=$55; driverFlags=$57; Flags=$59; phyErr=$61; phyErrStr=$63;
	
	# either we know it 
	if ( phyErrStr in PhyerrStrMap ){
		phyErrStr = PhyerrStrMap[phyErrStr];
	# or we don't
	} else {
		old = phyErrStr;
		phyErrStr = PhyerrStrMap["PyherrStrERROR"];
	}
	
	# just in case
	if ( phyErrStr == PhyerrStrMap["PyherrStrERROR"] ){	ignoreLine("unknown PhyerrStr" old ":"); next;}
	
	SECmore=$65; keyix=$67; packetLabel=$68; time=$69; 
	
	# replace ':' at end of time
	gsub(/:/, "", time);
	
	# PacketLabel: ATHOPERATION: 0, CRCerror: 1, CRC_TO_LONGerror: 2, OKPacket: 3, PHYerror: 4, PHY_TO_SHORTerror: 5, PHY_TO_LONGerror: 6, ZeroRateError: 7
	# ignore "ATHOPERATION:" and "PHY_TO_SHORTerror: and ZeroRateError
	if ( packetLabel == "ATHOPERATION:"){
		ignoreLine("ATHOPERATION"); # ignore
		next;
		packetLabelnum = PacketLabelMap[packetLabel];
	} else if (packetLabel == "PHY_TO_SHORTerror:"){
		ignoreLine("PHY_TO_SHORTerror"); #ingore
		next;
		packetLabelnum = PacketLabelMap[packetLabel];
	} else if ( packetLabel == "ZeroRateError:" ) {
		ignoreLine("ZeroRateError");#ignore
		next;
		packetLabelnum = PacketLabelMap[packetLabel];
	# either we know it 
	}else if ( packetLabel in PacketLabelMap ){
		packetLabelnum = PacketLabelMap[packetLabel];
	# or we don't
	} else {
		packetLabelnum = PacketLabelMap["PacketLabelERROR"];
	}
	
		
	
	# just in case
	if ( packetLabelnum == PacketLabelMap["PacketLabelERROR"] ){ignoreLine("unknown PacketLabel: " packetLabel);next;}
	
	#1286360669.405125:  140 |  1Mb +11/-96 |
	#time sizebytes | rate rssi/noise

	sizebytes=$70; 
	THRDRate=$72; 	
	# replace 'Mb' at end of rate
	gsub(/Mb/, "", THRDRate);
	
	# +11/-96
	split($73, rssiNoise,"/");
	THRDrssi=rssiNoise[1]; THRDnoise=rssiNoise[2];
	
	# FrameType FrameSubType
	# 71 72
	FrameTypeString = $75; 

	# either we know it 
	# if type in map take its integer 
	if ( FrameTypeString in FrameTypeMap ){		
		FrameType = FrameTypeMap[FrameTypeString];
	# if it is a new unknown subtype add it to the map 
	} else if ( /unknown-type-[0-9]+/ ) {
		# unknown type: we take the number at the end as negative error value
		split(FrameTypeString, tmp, "-" )
		FrameType = -tmp[3];
		FrameTypeMap[FrameTypeString] = -tmp[3];# save new unknown-type
	# else it is some other error
	} else {
		FrameType = FrameTypeMap["FrameTypeERROR"];
	}
	
	# just in case
	if ( FrameType == FrameTypeMap["FrameTypeERROR"] ){	ignoreLine("unknown FrameType: " FrameTypeString);next;}
	
	FrameSubTypeString = $76;
	
	# if type in map take its integer 
	if ( FrameSubTypeString in 	FrameSubTypeMap ){
		FrameSubType = FrameSubTypeMap[FrameSubTypeString];
	# if it is a new unknown subtype add it to the map 
	} else if ( /unknown-subtype-[0-9]+/ ) {
		# unknown subtype: we take the number at the end as negative error value
		split(FrameSubTypeString, tmp, "-" )
		FrameSubTypeMap[FrameSubTypeString] = -tmp[3];# using an offset
		FrameSubType = FrameSubTypeMap[FrameSubTypeString];
	# else it is some other error
	} else {
		FrameSubType = FrameSubTypeMap["FrameSubTypeERROR"];
	}
	
	# just in case
	if ( FrameSubType == FrameSubTypeMap["FrameSubTypeERROR"] ){	ignoreLine("unknown FrameSubTypeString: " FrameSubTypeString);next;}

	Addr1 = hexaMacToInt($77);
	Addr2 = hexaMacToInt($78);
	Addr3 = hexaMacToInt($79);
	
	# at this point we just scan the last columns for the following entries
	# ssid: -1 (none) -> might be hidden
	#		-2 (invalid_ssid)
	# 		-3 no ssid info in printout 
	# seq: -1 if none avaiable else it is the seqnr
	# if [ search for retry, IBSS, ESS, PRIVACY, CF_POLLABLE, CF_POLLREQ until you hit ]
	# set flags accordingly
	
	# defaults
	ssidStr = "notFound";
	#ssidInt;
	seq = -1;
	IBSS = 0;
	ESS = 0;
	PRIVACY = 0;
	CF_POLLABLE = 0;
	CF_POLLREQ = 0;
	Retry = 0;

	# start searching for the ssid: tag after the last mac entry
	i = 79;
	while ( i <= NF){
	
		# start of ssid
		if ( $i == "ssid:" ){
		
			i++;
			
			# in case the ssid itself is a whitespace than we would see the next tag 
			if ( $i == "rates:" || $i == "channel:" || $i == "seq:" || $i == "listen_int:" ){
				ssidStr = ""; # if so ssid is empty string

				break;
			} else {
				ssidStr = $i;
			}
		
		# end of ssid
		} else if ( $i == "rates:" || $i == "channel:" || $i == "seq:" || $i == "listen_int:") {
		
			break;
		
		# in between 
		} else if ( ssidStr != "notFound" ) {# add part of ssid if found
		
			ssidStr = ssidStr " " $i;
			
		}
		
		i++;
	}
	
	packetChan = -1;
	if ( $i == "channel:" ) {
		packetChan = $(i + 1);
	}
	
	# used - array has been initialized, see BEGIN {
	# map ssids into an array
    if ( ssidStr in used ){

    } else {
    	# add array entry used["SSID"] = 1 -> the ssid "SSID" has index 1
    	used[ssidStr] = usedSize-4;
    	usedSize++; # bug workoutround instead lenght()
    }	  
	ssidInt = used[ssidStr];
	
	while ( i <= NF ){
		
		if ($i == "seq:" ){
				i++;
				seq = $i;
		} else if ( $i == "IBSS") {
				IBSS = 1;
		} else if ( $i == "ESS" ) {
				ESS = 1;
		} else if ( $i == "PRIVACY") {
				PRIVACY = 1;
		} else if ( $i == "CF_POLLABLE") {
				CF_POLLABLE = 1;
		} else if ( $i == "CF_POLLREQ") {
				CF_POLLREQ = 1;
		} else if ( $i == "retry" ) {
				Retry = 1;
		}
		
		i++;
	
	}

	printf lat "\t" long "\t" alt  "\t" speed "\t" ath "\t" status "\t" rate "\t" rssi "\t" len "\t" more "\t" DCerr >> dataDat; 
	printf  "\t" ant "\t" done "\t" CRCerr "\t" decryptCRC "\t" SEClen "\t" ts "\t" SECstatus "\t" SECrate "\t" SECrssi >> dataDat;
	printf  "\t" SECant "\t" noise "\t" hosttime "\t" mactime "\t" channel "\t" channelUtil "\t" driverFlags "\t" Flags "\t" phyErr "\t" phyErrStr >> dataDat;
	printf  "\t" SECmore "\t" keyix "\t" packetLabelnum "\t" time "\t" sizebytes >> dataDat; 
	printf "\t" THRDRate "\t" THRDrssi "\t" THRDnoise "\t" FrameType "\t" FrameSubType "\t" Addr1 "\t" Addr2 "\t" Addr3 "\t" packetChan >> dataDat;
	printf "\t" ssidInt "\t" seq "\t" IBSS "\t" ESS "\t" PRIVACY "\t" CF_POLLABLE "\t" CF_POLLREQ "\t" Retry >> dataDat; 
	printf "\n" >> dataDat;


}

END {
	
	# contains two columns string and integer representation of the ssid
	for ( ssidStr in used ){
		print ssidStr "\t" used[ssidStr] >> SSIDMap; 
	}
	
	# contains String representation and integer
	for ( FrameType in FrameTypeMap ){
		print FrameType "\t" FrameTypeMap[FrameType] >> StringMap;
	}
	
	# contains String representation and integer
	for ( FrameSubType in FrameSubTypeMap ) {
	
		print FrameSubType "\t" FrameSubTypeMap[FrameSubType] >> StringMap;
	
	}
	printf "\n";
	
	close(SSIDMap);
	close(StringMap);
	close(dataDat);
	close(ignoredLinesLog);
	# move the files from tmp
	#printf("mv %s %s\n", StringMap, PREFIX.) | "sh"
	
}

	function check(i, errmsg){
	# this functions checks if their are enough data entries for a given number i
	# if not than error is printed and we jump to processing the next line 
		if ( NF < i ){
			ignoreLine(errmsg);
			return 0;
		}
		return 1;
		
    }  
    
    	function hexaMacToInt(mac){
		### start
		# convert mac address into integer
		# 00-01-36-06-86-FC to 0001360686FC	
	
		if ( mac == "FF-FF-FF-FF-FF-FF" ){
			return -1;
		} else if ( mac == "00-00-00-00-00-00" ){
			return 0;
		}
		
		# replace '-'
		gsub(/-/, "", mac);
		gsub(/\t/, "", mac);
		gsub(/ /, "", mac);
	
		#our general alphabet 
		alphabet="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
	
		# input base 
		ibase=16;  
	
		macinint = 0;
	
		#convert to decimal base 
		for (i=1;i<=length(mac);i++) { 
			val = (index(alphabet,substr(mac,i,1))-1);
			if (val>=0){
				macinint += (index(alphabet,substr(mac,i,1))-1)*(ibase^(length(mac)-i));
		        }
		} 
		return macinint;
	
	}
	
	function ignoreLine(errmsg){
		
		#print "Ignored line: " FNR " reason:" errmsg "  see: " ignoredLinesLog >> "/dev/stderr";
		print "Reason: " errmsg ": " $0 >> ignoredLinesLog; 
		return;
		#next;
	
	}
    
# evaluation/bin/start_evaluation.sh                 |   20 +++++++++-
# evaluation/scenarios/basic/eval.sh                 |   11 +++---> sucht *.dumps -> fromdump all.dat
# evaluation/scenarios/matlab/eval.sh                |   40 ++++++++++++++++++++ ----> nutzt all.dat macht tomatlab.sh
# channelutility driver flags
   

