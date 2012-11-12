#!/bin/sh

SENDERFILE=$1/sender.csv
RECEIVERFILE=$1/result.csv
INFOFILE=$1/info.csv
KMLFILE=$1/google/network.kml
GOOGLEDIR=$1/google
mkdir $GOOGLEDIR

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
	CHANNEL=`echo "$line" | sed "s#;# #g" | awk '{print $6}'`

cat >> $KMLFILE << EOF
	<Placemark>
		<name>$NAME</name>
		<description>
		<![CDATA[
			<h3>$NAME</h3>
			<table>
				<tr>
					<th>Name</th><th>Device</th><th>Longitude</th><th>Latitude</th><th>HOG</th><th>Channel</th>
				</tr>
				<tr>
					<td>$NAME</td><td>$DEVICE</td><td>$LONG</td><td>$LAT</td><td>$HOG</td><td>$CHANNEL</td>
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

POINTS=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2}' | sort -u`

for POINT in $POINTS; do

  NUMBER=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$1}' | grep "^$POINT " | awk '{print $2}' | tail -n 1`
  INFODIR=`cat $INFOFILE | egrep "^$NUMBER;" | sed "s#;# #g" | awk '{print $2}' | sed "s#\"##g"`

  if [ -e $INFODIR/info ]; then	
    DAY=`cat $INFODIR/info | grep "DATE:" | awk '{print $2}' | sed "s#:#/#g"`
    TIME=`cat $INFODIR/info | grep "DATE:" | awk '{print $3}'`
  else
     DAY="-"
     TIME="-"
  fi

  NODES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3}' | grep "^$POINT " | awk '{print $2}' | sort -u`

  for NODE in $NODES; do

    DEVICES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4}' | grep "^$POINT $NODE " | awk '{print $3}' | sort -u`

    for DEVICE in $DEVICES; do
      NUMBER=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$1}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`
      CHANNEL=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$5}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`
      LONG=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$6}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`
      LAT=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$7}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`
      HOG=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$8}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`

      PACKETS_ALL_ALL=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$16}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | tail -n 1`
      PACKETS_ALL_OK=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$17}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | tail -n 1`
      PACKETS_ALL_CRC=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$18}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | tail -n 1`
      PACKETS_ALL_PHY=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$19}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | tail -n 1`
      DURATION=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$15}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | tail -n 1`

      if [ ! "x$LONG" = "x0" ] && [ ! "x$LAT" = "x0" ]; then 
 
cat >> $KMLFILE << EOF
	<Placemark>
		<name>POINT $POINT ($NODE:$DEVICE)</name>
		<description>
		<![CDATA[
			<h3>Node</h3>
			Date: $DAY $TIME
			<table>
				<tr>
					<th>Name</th><th>Device</th><th>Longitude</th><th>Latitude</th><th>HOG</th><th>Channel</th><th>Duration</th>
				</tr>
				<tr>
					<td>$NODE</td><td>$DEVICE</td><td>$LONG</td><td>$LAT</td><td>$HOG</td><td>$CHANNEL</td><td>$DURATION</td>
				</tr>
			</table>
			<h3>General Packetstats</h3>
			<table>
				<tr>
					<th>Sum</th><th>OK</th><th>CRC-Error</th><th>Phy-Error</th>
				</tr>
				<tr>
					<td>$PACKETS_ALL_ALL</td><td>$PACKETS_ALL_OK</td><td>$PACKETS_ALL_CRC</td><td>$PACKETS_ALL_PHY</td>
				</tr>
			</table>

EOF

        SENDERS=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9}' | grep "^$POINT $NODE $DEVICE " | awk '{print $4}' | sort -u`

        for SENDERNAME in $SENDERS; do

          SENDERDEVICES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10}' | grep "^$POINT $NODE $DEVICE $SENDERNAME " | awk '{print $5}' | sort -u`

          for SENDERDEVICE in $SENDERDEVICES; do

            SENDERLONG=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$11}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE " | awk '{print $6}' | sort -u`
            SENDERLAT=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$12}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE " | awk '{print $6}' | sort -u` 
            SENDERHOG=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$13}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE " | awk '{print $6}' | sort -u`
            DISTANCE=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$14}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE " | awk '{print $6}' | sort -u`

cat >> $KMLFILE << EOF
			<h3>Sender</h3>
			<table>
				<tr>
					<th>Name</th><th>Device</th><th>Longitude</th><th>Latitude</th><th>HOG</th><th>Channel</th><th>Distance</th>
				</tr>
				<tr>
					<td>$SENDERNAME</td><td>$SENDERDEVICE</td><td>$SENDERLONG</td><td>$SENDERLAT</td><td>$SENDERHOG</td><td>$CHANNEL</td><th>$DISTANCE</th>
				</tr>
			</table>
EOF

            BITRATES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE " | awk '{print $6}' | sort -u`

            for BITRATE in $BITRATES; do

              SIZES=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE " | awk '{print $7}' | sort -u`

              for SIZE in $SIZES; do

                PACKETS_OWN_INTERVAL=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$22}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                PACKETS_OWN_ALL=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$23}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                PACKETS_OWN_OK=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$24}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                PACKETS_OWN_CRC=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$25}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                PACKETS_OWN_PHY=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$26}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                PER=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$27}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                STDPER=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$28}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                MEANRSSI=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$29}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`
                STDRSSI=`cat $RECEIVERFILE | grep -v "NUMBER" | sed "s#;# #g" | awk '{print $2" "$3" "$4" "$9" "$10" "$21" "$20" "$30}' | grep "^$POINT $NODE $DEVICE $SENDERNAME $SENDERDEVICE $BITRATE $SIZE " | awk '{print $8}'`

cat >> $KMLFILE << EOF
			<h4>Packets</h4>
			<table>
				<tr>
					<th>Duration</th><th>Size</th><th>Bitrate</th><th>Interval</th><th>Sum</th><th>OK</th><th>CRC-Error</th><th>Phy-Error</th><th>PER (OK)</th><th>STDPER (OK)</th><th>Mean-RSSI</th><th>Std. Dev. RSSI</th>
				</tr>
				<tr>
					<td>$DURATION</td><td>$SIZE</td><td>$BITRATE</td><td>$PACKETS_OWN_INTERVAL</td><td>$PACKETS_OWN_ALL</td><td>$PACKETS_OWN_OK</td><td>$PACKETS_OWN_CRC</td><td>$PACKETS_OWN_PHY</td><td>$PER</td><td>$STDPER</td><td>$MEANRSSI</td><td>$STDRSSI</td>
				</tr>
			</table>
EOF

                if [ -e $1/$POINT/$NODE.$DEVICE.packets.all.all.matlab.$SIZE.$BITRATE.png ]; then
                  if [ ! -e $GOOGLEDIR/$POINT ]; then
                    mkdir $GOOGLEDIR/$POINT
                  fi

                  cp $1/$POINT/$NODE.$DEVICE.packets.all.all.matlab.$SIZE.$BITRATE.png $GOOGLEDIR/$POINT/ 
cat >> $KMLFILE << EOF
			        <h3>Graphs</h3>
			        <h4>Node: $NODE Device: $DEVICE Packetsize: $SIZE Bitrate: $BITRATE</h4>
				<img src="$POINT/$NODE.$DEVICE.packets.all.all.matlab.$SIZE.$BITRATE.png" alt="graph">
				<p>
EOF
                  if [ -e $1/$POINT/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error.png ]; then
                     cp $1/$POINT/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error.png $GOOGLEDIR/$POINT/
cat >> $KMLFILE << EOF
			        CRC
				<img src="$POINT/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error.png" alt="crc">
				<p>
EOF
                  fi			    
                fi
#size
              done
#bitrate
            done
#senderdevice
          done
#sendername
        done

cat >> $KMLFILE << EOF
			<h3>Info</h3>
EOF
			if [ -e $INFODIR/info ]; then
				cat $INFODIR/info | grep -v "DATE:" >> $KMLFILE
			else
				echo "No Info" >> $KMLFILE
			fi
			
cat >> $KMLFILE << EOF
		<p>
		<h3>Headman</h3>
		<img src="az.png" alt="Headman">
		]]>
		</description>
		<Point>
			<coordinates>$LONG,$LAT,$HOG</coordinates>
		</Point>
	</Placemark>
EOF
      fi #END of valid coord

#device
    done
#node
  done
#point
done 

cat >> $KMLFILE << EOF
</Document>
</kml>
EOF

cp az.png $GOOGLEDIR/
rm -f $GOOGLEDIR/../network.kmz
(cd $GOOGLEDIR/; zip -r ../network.kmz *)
rm -rf $GOOGLEDIR

exit 0
