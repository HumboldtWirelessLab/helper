#!/bin/sh

if [ ! -e ./eq_sim ]; then
make
fi

if [ $# -eq 0 ]; then
  echo "Use $0 NODENUMBER RUNTIME FIELDSIZE MINDIST MAXDIST EVENTTIME"
  exit 0
fi
../../../simulation/bin/generate_simulation.sh $1 event.click $2 $3
./eq_sim rand $1 $3 $4 $5 $6 > eq.stats

cat ./eq.stats | sed '1,1d' | awk '{print "node"NR" "$2" "$4" 0"}' > placement.plm
cat ./eq.stats | sed '1,1d' | awk '{print "node"NR" write en.event "$6}' > handler.do 

cat simulation.dis | sed -e "s#[[:space:]]*NODEPLACEMENTFILE[[:space:]]*=.*#NODEPLACEMENTFILE=placement.plm#g" -e "s#[[:space:]]*NODEPLACEMENT[[:space:]]*=.*#NODEPLACEMENT=FILE#g" > simulation.dis.tmp
mv simulation.dis.tmp simulation.dis

echo "HANDLERSCRIPT=CONFIGDIR/handler.do" >> simulation.dis

exit 0
