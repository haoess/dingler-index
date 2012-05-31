#!/bin/bash

PAGEDIR=/home/fw/dingler-pages

echo "removing doubled pb's ..."
bin/remove-doubled-pbs.pl -o "$PAGEDIR" ~/src/kuwi/dingler/pj*/*.xml

echo
echo "splitting pages ..."
for i in $PAGEDIR/*.xml; do
  echo
  echo "splitting up $i ..."
  bin/split-pages.pl -f $i -o "$PAGEDIR"/`basename $i .xml`
done
