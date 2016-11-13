#! /bin/bash

MONTH_FIRST_DAYS=$(for date in $(cat data/index_data/dates.txt); do echo ${date:0:6}01; done | sort -u)

for MONTH_FIRST_DAY in $MONTH_FIRST_DAYS; do
    END=$(date +%Y%m%d -d "$MONTH_FIRST_DAY +1 month")
    echo data/index_data/${MONTH_FIRST_DAY}_${END}.csv
done
