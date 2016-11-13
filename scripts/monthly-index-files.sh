#! /bin/bash

MONTHLY_INTERVAL_SCRIPT=$(dirname $0)/monthly-intervals.sh

for interval in $(MONTHLY_INTERVAL_SCRIPT); do
    echo data/index_data/${interval}.csv
done
