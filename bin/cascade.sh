#!/bin/bash

for i in "$@"; do
  bin/postgres_build_index.pl "$i"
  bin/postgres_patents.pl "$i"
done

echo "rebuild stats cache ..."
rm -rf var/cache/dingler-records
script/dingler_test.pl / >/dev/null 2>&1

echo "rebuild records cache ..."
rm -rf var/cache/dingler-stats
script/dingler_test.pl /records >/dev/null 2>&1
