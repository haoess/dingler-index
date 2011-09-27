#!/bin/bash

which parallel > /dev/null
HAVE_PARALLEL="$?"

#################################################

psql -d dingler2 < db/schema.sql

#################################################

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

#################################################

echo "killing dingler web apps ..."
kill `cat /tmp/dingler.pid`
kill `cat /tmp/dingler-beta.pid`
sleep 5

#################################################

dropdb dingler
createdb -T dingler2 dingler
psql -d dingler < db/grant.sql

#################################################

./start

#################################################

sleep 5

kill `cat var/sphinx/searchd.pid`

sleep 5

echo "rebuild sphinx index ..."
indexer --config sphinx.conf --all
searchd

#################################################

rm -rf var/cache/dingler-*

echo "rebuild stats cache ..."
script/dingler_test.pl / >/dev/null 2>&1

echo "rebuild records cache ..."
script/dingler_test.pl /records >/dev/null 2>&1

#################################################

cd ../dingler-beta
./start

rm -rf var/cache/dingler-*

echo "rebuild stats cache ..."
script/dingler_test.pl / >/dev/null 2>&1

echo "rebuild records cache ..."
script/dingler_test.pl /records >/dev/null 2>&1
