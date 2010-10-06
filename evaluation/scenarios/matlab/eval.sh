
for d in `(ls *.dump.all.dat)`; do

RXFILE=`echo $d | sed "s#all\.dat#rx\.dat#g"`
RXBASEFILE=`echo $d | sed "s#all\.dat#rx\.base\.dat#g"`
RXWIFITYPEFILE=`echo $d | sed "s#all\.dat#rx\.wifitype\.dat#g"`
RXADDRFILE=`echo $d | sed "s#all\.dat#rx\.addr\.dat#g"`

cat $d | grep -P "ATH: \(RX\)" > $RXFILE

# only a test: print all possible values
if false ; then
	for i in 1 3 5 7 9 10 11 12 13 14 15 20 21 22 23 24 25 26 27 28 29 30 31 32 37 38 39 40 41 44 45 52 53 54 55 56 57 58 59 60 61 62; do
		val=`cat devel.$device.rx.dat | awk -v pos=$i '{ print $pos }' | sort -u`
		echo "$i: $val"
	done
fi

# LAT LONG ALT SPEED ATH Status Rate RSSI LEN More DCErr Ant Done CRCErr DecryptCRC Len TS Status Rate RSSI Ant Noise  Hosttime Mactime Channel Phyerr PhyerrStr More Keyix PacketLabel Time LenNoCRC
# 2 4 6 8 10 12 15 17 19 21 23 25 27 29 31 34 36 38 41 43 45 47 49 51 53 55 57 59 61 62 63 64

# ATH :(RX) = receive frame -> 0, (TX) = receive frame -> 1
# PhyerrStr : (HAL_PHYERR_CCK_RESTART) -> 0, (HAL_PHYERR_OFDM_RESTART) -> 1, (HAL_PHYERR_TOR) -> 2, (none) -> 3
# PacketLabel: ATHOPERATION: 0, CRCerror: 1, CRC_TO_LONGerror: 2, OKPacket: 3, PHYerror: 4, PHY_TO_SHORTerror: 5, PHY_TO_LONGerror: 6, ZeroRateError: 7

cat $RXFILE | awk '{ print $2 " " $4 " " $6 " " $8 " " $10 " " $12 " " $15 " " $17 " " $19 " " $21 " " $23 " " $25 " " $27 " " $29 " " $31 " " $34 " " $36 " " $38 " " $41 " " $43 " " $45 " " $47 " " $49 " " $51 " " $53 " " $55 " " $57 " " $59 " " $61 " " $62 " " $63 " " $64 }' | sed -s 's/(RX)/0/g' | sed -s 's/(TX)/1/g' | sed -s 's/(HAL_PHYERR_CCK_RESTART)/0/g' | sed -s 's/(HAL_PHYERR_OFDM_RESTART)/1/g' | sed -s 's/(HAL_PHYERR_TOR)/2/g' | sed -s 's/(none)/3/g' | sed -s 's/ATHOPERATION:/0/g' | sed -s 's/CRCerror:/1/g' | sed -s 's/CRC_TO_LONGerror:/2/g' | sed -s 's/OKPacket:/3/g' | sed -s 's/PHYerror:/4/g' | sed -s 's/PHY_TO_SHORTerror:/5/g' | sed -s 's/PHY_TO_LONGerror:/6/g' | sed -s 's/ZeroRateError:/7/g' | sed -s 's/://g' > $RXBASEFILE

# FrameType FrameSubType
# 69 70
cat $RXFILE | grep -P -v "ATHOPERATION:" | grep -P -v "PHY_TO_SHORTerror:" | awk '{ print $51 " " $63 " " $69 " " $70 }' | sed -s 's/unknown-subtype-//g' | sed -s 's/unknown-type-//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' | sed -s 's/psp/0/g' | sed -s 's/rts/1/g' | sed -s 's/cts/2/g' | sed -s 's/ack/3/g' | sed -s 's/cfe/4/g' | sed -s 's/cfea/5/g' | sed -s 's/nods/6/g'  | sed -s 's/tods/7/g' | sed -s 's/frds/8/g' | sed -s 's/dsds/9/g' | sed -s 's/reassoc_req/10/g' | sed -s 's/reassoc_resp/11/g' | sed -s 's/assoc_req/12/g' | sed  -s 's/assoc_resp/13/g' | sed -s 's/disassoc/14/g' | sed -s 's/probe_req/15/g' | sed -s 's/probe_resp/16/g' | sed -s 's/beacon/17/g'  | sed -s 's/deauth/18/g' | sed -s 's/auth/19/g'  | sed -s 's/atim/20/g' | sed -s 's/://g' > $RXWIFITYPEFILE

# MAC1 MAC2 MAC3
# 71 72 73
#cat devel.$device.rx.dat | grep -P -v "ATHOPERATION:" | grep -P -v "PHY_TO_SHORTerror:" | awk '{ print $51 " " $63 " " $71 " " $72 " " $73 }'  > $RXADDRFILE


#LAT: 52.506551 LONG: 13.332575 ALT: 81.100000 SPEED: 0.0  ATH: (RX) Status: 0 (OK) Rate: 2 RSSI: 14 LEN: 105 More: 0 DCErr: 0 Ant: 1 Done: 1 CRCErr: 0 DecryptCRC: 0 (RX) Len: 105 TS: 19660 Status: 0 (OK) Rate: 2 RSSI: 14 Ant: 1 Noise: -96 Hosttime: 4294948371 Mactime: 192007372 Channel: 1 Phyerr: 0 PhyerrStr:  (none) More: 0 Keyix: 255 OKPacket: 1285927390.358213:  101 |  1Mb +14/-96 | mgmt beacon 00-24-01-42-02-79 Reiseland-Zoo chan 1 b_int 100 [ ESS PRIVACY ] ({2 4 11 22} 12 24 48 72 18 36 96 108)
#LAT: 52.506551 LONG: 13.332575 ALT: 81.100000 SPEED: 0.0  ATH: (RX) Status: 0 (OK) Rate: 2 RSSI: 16 LEN: 82 More: 0 DCErr: 0 Ant: 1 Done: 1 CRCErr: 0 DecryptCRC: 0 (RX) Len: 82 TS: 8596 Status: 0 (OK) Rate: 2 RSSI: 16 Ant: 1 Noise: -96 Hosttime: 4294948466 Mactime: 192389524 Channel: 1 Phyerr: 0 PhyerrStr:  (none) More: 0 Keyix: 255 OKPacket: 1285927390.740402:   78 |  1Mb +16/-96 | data frds FF-FF-FF-FF-FF-FF 00-15-E9-C1-0E-A0 00-40-63-FA-32-D9 seq 1860 [ ]

done