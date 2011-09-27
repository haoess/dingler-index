#!/bin/bash

echo "removing doubled pb's ..."
bin/remove-doubled-pbs.pl -o ~/dingler-pages ~/src/kuwi/dingler/pj*/*.xml

echo "splitting pages ..."
for i in ~/dingler-pages/*.xml; do
  bin/split-pages.pl -f $i -o ~/dingler-pages/`basename $i .xml`
done
