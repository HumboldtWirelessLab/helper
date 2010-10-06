#!/bin/sh

if [ "x$1" = "xhelp" ]; then
  echo "Use $0 [country]"
  echo "Country: japan, germany"
fi

for i in `ls *channel*`; do
  cat $i | grep -v "RECOMMENDMODOPTIONS" > $i.new
  mv $i.new $i
  if [ "x$1" != "x" ]; then
    echo "RECOMMENDMODOPTIONS=modoptions.$1" >> $i
  fi
done
