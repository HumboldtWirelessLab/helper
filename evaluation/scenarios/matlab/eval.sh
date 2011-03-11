
for d in `(ls *.dump.all.dat)`; do

# prefix is the * part before .dump.all.dat 
PREFIX=`echo $d | sed "s#\.dump\.all\.dat##g"`

# This script generates 3 files:
# PREFIX.ssid.idx			: contains all ssid and their integer representation
# PREFIX.stringmap.idx		: contains all string values used and their integer representation
# PREFIX.data.dat			: contains all the data formated to integer values
# PREFIX.ignoredlines.log	: contains ignored lines like TX, ATHOPERATION or faulty formats.
# 	Further Infos see the awk script itself. 
cat $d | awk -vPREFIX=$PREFIX -f genMatlabFile.awk

done
