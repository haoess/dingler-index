#!/bin/bash

echo "persons.xml to sql ..."
bin/postgres_build_persons.pl

echo "start basic database build ..."
for i in "$@"; do
  bin/postgres_build_index.pl "$i"
done

echo "start patent database setup ..."
for i in "$@"; do
  bin/postgres_patents.pl "$i"
done

echo "map person references ..."
for i in "$@"; do
  bin/postgres_build_personrefs.pl "$i"
done

echo "rebuild sphinx index ..."
indexer --config sphinx.conf --all

echo "rebuild stats cache ..."
rm -rf var/cache/dingler-records
script/dingler_test.pl / >/dev/null 2>&1

echo "rebuild records cache ..."
rm -rf var/cache/dingler-stats
script/dingler_test.pl /records >/dev/null 2>&1
