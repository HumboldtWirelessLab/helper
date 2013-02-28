#/bin/bash


# Script to convert a hexadecimal dump file to decimal.
# Here xxd is used to create a C-header that contains an array with the given
# data and a self-written little C-File that prints that array.


DUMPFILE=regmon_dump
DUMPFILE_DEC="$DUMPFILE.dec"


if [ $# -gt 1 ]; then
  echo "$@"
  for i in $@; do
    $0 $i
  done
  exit 0
fi


if [ "x$1" = "x" ]; then
  echo "Use $0 file"
  exit 0
fi

if [ "$1" != "$DUMPFILE" ]; then
  cp $1 $DUMPFILE
  DUMPFILE_DEC=$1.dec
fi



CONVERTFILE=hex2dec.c
CONVERTBIN=hex2dec


#check for the regmon data hexdump
if [ ! -f ./${DUMPFILE} ]; then
	echo "ERROR: Specified Regmon data file doesn't exist."
	exit -1;
fi

rm -f $CONVERTFILE ${CONVERTBIN} ${DUMPFILE}.h


cat >> $CONVERTFILE << EOF 
#include <stdio.h>
#include <inttypes.h>

#include "regmon_dump.h"


int main(void)
{
  int i;
  int j;
  int c;

  uint32_t *p = (int*) regmon_dump;
  uint32_t max = sizeof(regmon_dump)-32;
  max /= 32;

  c = 0;
			
  for( i = 0; i < max; i++ ) {
    for( j = 0; j < 7; j++ ) {
      printf("%u ", p[c]);
      c++;
    }
    uint64_t tv64 = p[c-5];
    tv64 = tv64 << 32;
    tv64 += (uint64_t)p[c-6];
    printf("%llu ",tv64);

    for( j = 0; j < 1; j++ ) {
      printf("%u", p[c]);
      c++;
    }
    printf("\n");
  }
}
EOF

# create a C-header containing the dump data as an array
xxd -i ${DUMPFILE} ${DUMPFILE}.h

# build the converter program
gcc ${CONVERTFILE} -o ${CONVERTBIN}

if [ -f ./${CONVERTBIN} ]; then # use it
	./${CONVERTBIN} > ${DUMPFILE_DEC}
fi

rm -f $CONVERTFILE ${CONVERTBIN} ${DUMPFILE}.h

if [ "$1" != "$DUMPFILE" ]; then
  rm -f $DUMPFILE
fi

# echo "${CONVERTBIN} done."
