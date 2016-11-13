#! /bin/bash

stat=$1

MONTHLY_INTERVAL_SCRIPT=$(dirname $0)/monthly-intervals.sh
AREAS=$(ls areas/*.json | sed 's/^areas\///g' | sed 's/\.json$//g')

for interval in $($MONTHLY_INTERVAL_SCRIPT); do
    for area in $AREAS; do
        echo data/index_values/$area/$stat/$interval.json
    done
done
