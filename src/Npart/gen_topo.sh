#!/bin/sh
NPART_DIR=`pwd`

#  -h, --help           print this message
#  -n, --nodes          number of nodes: n [50] 
#  -a, --arrange        uniform/uniformConnected/distroFF/distroL
#  -x, --xDimension     x-dimension of placement area for uniform placements
#  -y, --yDimension     y-dimension of placement area for uniform placements
#  -r, --radius         comm. radius (without effects of shadowing/fading!)
#  -t, --retries        retries parameter of NPART (how many candidates shall be evaluated)
#  -p, --penalty        penalty for degree overloading
#  -s, --secondaryWgh   secondary weight parameter for npart
#  -c, --count          Topology count: how many topologies to generate
#  -d, --reduction      reduction of pendant node count
#  -o, --output         output file type: ns2/dot [ns2]

javac -cp lib/jargs.jar:lib/mantissa-7.2.jar src/NPART/*.java > /dev/null 2>&1
javac -cp lib/jargs.jar:lib/mantissa-7.2.jar src/Visualize/*.java > /dev/null 2>&1

if [ "x$RXRANGE" = "x" ]; then
  RXRANGE=100
fi

#java -classpath $NPART_DIR/classes/:$NPART_DIR/lib/jargs.jar:$NPART_DIR/lib/mantissa-7.2.jar NPART.TopologyGenerator -h

#java -classpath $NPART_DIR/src:$NPART_DIR/lib/jargs.jar:$NPART_DIR/lib/mantissa-7.2.jar NPART.TopologyGenerator -n $1 -r $RXRANGE -d 0.8 -o ts -p 5 -c 1 -t 150 -a distroFF
java -classpath $NPART_DIR/src:$NPART_DIR/lib/jargs.jar:$NPART_DIR/lib/mantissa-7.2.jar NPART.TopologyGenerator -n $1 -r $RXRANGE -d 0.2 -o ts -p 15 -c 1 -t 150 -a distroL
#java -classpath $NPART_DIR/src:$NPART_DIR/lib/jargs.jar:$NPART_DIR/lib/mantissa-7.2.jar NPART.TopologyGenerator -n $1 -r $RXRANGE -d 0.2 -o ts -p 15 -c 1 -t 150 -a distroL