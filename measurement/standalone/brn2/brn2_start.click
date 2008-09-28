d1 :: BRN2Device(DEVICENAME "ath0", ETHERADDRESS 00:00:00:00:00:01 , DEVICETYPE "WIRED");
d2 :: BRN2Device(DEVICENAME "ath1", ETHERADDRESS 00:00:00:00:00:02 , DEVICETYPE "WIRELESS");

id :: BRN2NodeIdentity( d1, d2 );

Script(
 wait 1,
 read d1.deviceinfo,
 read d2.deviceinfo,
 stop
);
 