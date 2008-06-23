#!/bin/sh

SENDERFILE=$1/sender.csv
RECEIVERFILE=$1/result.csv
INFOFILE=$1/info.csv
KMLFILE=$1/network.kml

cat > $KMLFILE << EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.2">
<Document>
	<name>network.kml</name>
	<Style id="sh_ylw-pushpin_copy1">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
	<StyleMap id="msn_ylw-pushpin_copy1">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_ylw-pushpin_copy1</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin_copy1</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sn_ylw-pushpin_copy1">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
EOF

while  read line; do
	NAME=`echo "$line" | sed "s#;# #g" | awk '{print $1}'`
          DEVICE=`echo "$line" | sed "s#;# #g" | awk '{print $2}'`
	LONG=`echo "$line" | sed "s#;# #g" | awk '{print $3}'`
	LAT=`echo "$line" | sed "s#;# #g" | awk '{print $4}'`
	HOG=`echo "$line" | sed "s#;# #g" | awk '{print $5}'`
cat >> $KMLFILE << EOF
	<Placemark>
		<name>$NAME</name>
		<description>
		<![CDATA[
			<h3>$NAME</h3>
			<table>
				<tr>
					<th>Name</th><th>Device</th><th>Longitude</th><th>Latitude</th><th>HOG</th>
				</tr>
				<tr>
					<td>$NAME</td><td>$DEVICE</td><td>$LONG</td><td>$LAT</td><td>$HOG</td>
				</tr>
			</table>
		]]>
		</description>
		<Point>
			<coordinates>$LONG,$LAT,$HOG</coordinates>
		</Point>
	</Placemark>
EOF
	
done < $SENDERFILE

RESULTLINES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print ";"$2";"$3";"$4";"}' | sort -u`

for rline in $RESULTLINES; do
	line=`cat $RECEIVERFILE | grep $rline | tail -n 1`
	NUMBER=`echo "$line" | sed "s#;# #g" | awk '{print $1}'`
	POINT=`echo "$line" | sed "s#;# #g" | awk '{print $2}'`
	NAME=`echo "$line" | sed "s#;# #g" | awk '{print $3}'`
          DEVICE=`echo "$line" | sed "s#;# #g" | awk '{print $4}'`
	LONG=`echo "$line" | sed "s#;# #g" | awk '{print $5}'`
	LAT=`echo "$line" | sed "s#;# #g" | awk '{print $6}'`
	HOG=`echo "$line" | sed "s#;# #g" | awk '{print $7}'`
	SENDERNAME=`echo "$line" | sed "s#;# #g" | awk '{print $8}'`
          SENDERDEVICE=`echo "$line" | sed "s#;# #g" | awk '{print $9}'`
	SENDERLONG=`echo "$line" | sed "s#;# #g" | awk '{print $10}'`
	SENDERLAT=`echo "$line" | sed "s#;# #g" | awk '{print $11}'`
	SENDERHOG=`echo "$line" | sed "s#;# #g" | awk '{print $12}'`
	DISTANCE=`echo "$line" | sed "s#;# #g" | awk '{print $13}'`
	DURATION=`echo "$line" | sed "s#;# #g" | awk '{print $14}'`

	PACKETS_ALL_ALL=`echo "$line" | sed "s#;# #g" | awk '{print $15}'`
          PACKETS_ALL_OK=`echo "$line" | sed "s#;# #g" | awk '{print $16}'`
	PACKETS_ALL_CRC=`echo "$line" | sed "s#;# #g" | awk '{print $17}'`
	PACKETS_ALL_PHY=`echo "$line" | sed "s#;# #g" | awk '{print $18}'`

	INFODIR=`cat $INFOFILE | egrep "^$NUMBER;" | sed "s#;# #g" | awk '{print $2}' | sed "s#\"##g"`

if [ ! "x$LONG" = "x0" ] && [ ! "x$LAT" = "x0" ]; then 

cat >> $KMLFILE << EOF
	<Placemark>
		<name>POINT $POINT ($NAME)</name>
		<description>
		<![CDATA[
EOF
			if [ -e $INFODIR/info ]; then	
				DAY=`cat $INFODIR/info | grep "DATE:" | awk '{print $2}' | sed "s#:#/#g"`
				TIME=`cat $INFODIR/info | grep "DATE:" | awk '{print $3}'`
				echo "Date: $DAY $TIME" >> $KMLFILE
			else
				echo "Date: -" >> $KMLFILE
			fi
cat >> $KMLFILE << EOF
			<h3>Nodes</h3>
			<table>
				<tr>
					<th></th><th>Name</th><th>Device</th><th>Longitude</th><th>Latitude</th><th>HOG</th><th>Distance</th>
				</tr>
				<tr>
					<td>Receiver</td><td>$NAME</td><td>$DEVICE</td><td>$LONG</td><td>$LAT</td><td>$HOG</td><td>$DISTANCE</td>
				</tr>
				<tr>
					<td>Sender</td><td>$SENDERNAME</td><td>$SENDERDEVICE</td><td>$SENDERLONG</td><td>$SENDERLAT</td><td>$SENDERHOG</td><td>0</td>
				</tr>
			</table>
			<h3>Packetstats</h3>
			<h4>All</h4>
			<table>
				<tr>
					<th>Sum</th><th>OK</th><th>CRC-Error</th><th>Phy-Error</th><th>PER</th><th>Mean-RSSI</th><th>Std. Dev. RSSI</th>
				</tr>
				<tr>
					<td>$PACKETS_ALL_ALL</td><td>$PACKETS_ALL_OK</td><td>$PACKETS_ALL_CRC</td><td>$PACKETS_ALL_PHY</td><td>-</td><td>-</td><td>-</td>
				</tr>
			</table>
			<h4>Own</h4>
			<table>
				<tr>
					<th>Duration</th><th>Size</th><th>Bitrate</th><th>Interval</th><th>Sum</th><th>OK</th><th>CRC-Error</th><th>Phy-Error</th><th>PER (OK) </th><th>Mean-RSSI</th><th>Std. Dev. RSSI</th>
				</tr>
EOF

while  read line; do
	INC_LINE=`echo "$line" | grep $rline | wc -l | awk '{print $1}'`
	if [ $INC_LINE -eq 1 ]; then
          	PACKETS_OWN_SIZE=`echo "$line" | sed "s#;# #g" | awk '{print $19}'`
		PACKETS_OWN_BITRATE=`echo "$line" | sed "s#;# #g" | awk '{print $20}'`
          	PACKETS_OWN_INTERVAL=`echo "$line" | sed "s#;# #g" | awk '{print $21}'`
		PACKETS_OWN_ALL=`echo "$line" | sed "s#;# #g" | awk '{print $22}'`
		PACKETS_OWN_OK=`echo "$line" | sed "s#;# #g" | awk '{print $23}'`
          	PACKETS_OWN_CRC=`echo "$line" | sed "s#;# #g" | awk '{print $24}'`
		PACKETS_OWN_PHY=`echo "$line" | sed "s#;# #g" | awk '{print $25}'`
		PER=`echo "$line" | sed "s#;# #g" | awk '{print $26}'`
		MEANRSSI=`echo "$line" | sed "s#;# #g" | awk '{print $27}'`
		STDRSSI=`echo "$line" | sed "s#;# #g" | awk '{print $28}'`

cat >> $KMLFILE << EOF
				<tr>
					<td>$DURATION</td><td>$PACKETS_OWN_SIZE</td><td>$PACKETS_OWN_BITRATE</td><td>$PACKETS_OWN_INTERVAL</td><td>$PACKETS_OWN_ALL</td><td>$PACKETS_OWN_OK</td><td>$PACKETS_OWN_CRC</td><td>$PACKETS_OWN_PHY</td><td>$PER</td><td>$MEANRSSI</td><td>$STDRSSI</td>
				</tr>
EOF
	fi
done < $RECEIVERFILE

cat >> $KMLFILE << EOF
			</table>
			<h3>Info</h3>
EOF
			if [ -e $INFODIR/info ]; then
				cat $INFODIR/info | grep -v "DATE:" >> $KMLFILE
			else
				echo "No Info" >> $KMLFILE
			fi

cat >> $KMLFILE << EOF
		<p>
		]]>
		</description>
		<Point>
			<coordinates>$LONG,$LAT,$HOG</coordinates>
		</Point>
	</Placemark>
EOF


fi #END of valid coord
done 

cat >> $KMLFILE << EOF
</Document>
</kml>
EOF

exit 0

