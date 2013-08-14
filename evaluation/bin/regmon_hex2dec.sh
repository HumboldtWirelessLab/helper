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

  /*estimate size*/
  //printf("sizeof: %lu\n", sizeof(regmon_dump));
  uint32_t structsize = 28;

  for (;((sizeof(regmon_dump) % structsize) != 0) && (structsize < 56); structsize += 4);
  if ( structsize == 56 ) structsize = 28;

  uint32_t cnt_structvalues = structsize / 4;

  uint32_t max = sizeof(regmon_dump) - structsize;
  max /= structsize;

  c = 0;

  for( i = 0; i < max; i++ ) {
    for( j = 0; j < 7; j++ ) {   // jiffies nsec sec cycles busy_cycles rx_cycles tx_cycles
      printf("%u ", p[c]);
      c++;
    }
    uint64_t tv64 = p[c-5];      // get sec
    tv64 = tv64 << (uint64_t)32; // shift (sec to nsec)
    tv64 += (uint64_t)p[c-6];    // add nsec
    printf("%" PRIu64 " ",tv64);

    for(; j < cnt_structvalues; j++ ) {
      printf("%u ", p[c]);
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
