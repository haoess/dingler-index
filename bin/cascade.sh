#!/bin/bash

which parallel > /dev/null
HAVE_PARALLEL="$?"

echo "persons.xml to sql ..."
bin/postgres_build_persons.pl

echo "start basic database build ..."
if [ $HAVE_PARALLEL -eq 0 ]; then
  parallel -j-1 bin/postgres_build_index.pl ::: $@
else
  for i in "$@"; do
    bin/postgres_build_index.pl "$i"
  done
fi

echo "start patent database setup ..."
if [ $HAVE_PARALLEL -eq 0 ]; then
  parallel -j-1 bin/postgres_patents.pl ::: $@
else
  for i in "$@"; do
    bin/postgres_patents.pl "$i"
  done
fi

echo "map person references ..."
if [ $HAVE_PARALLEL -eq 0 ]; then
  parallel -j-1 bin/postgres_build_personrefs.pl ::: $@
else
  for i in "$@"; do
    bin/postgres_build_personrefs.pl "$i"
  done
fi

echo "rebuild sphinx index ..."
indexer --config sphinx.conf --all

echo "rebuild stats cache ..."
rm -rf var/cache/dingler-records
script/dingler_test.pl / >/dev/null 2>&1

echo "rebuild records cache ..."
rm -rf var/cache/dingler-stats
script/dingler_test.pl /records >/dev/null 2>&1
