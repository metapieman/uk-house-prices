#! /bin/bash

DATE=20050101
LAST_MONTH_START=$(date +%Y%m%d -d "$(date +%Y%m)01 -1 month")

while [ $DATE -ne $LAST_MONTH_START ]; do
    NEXT_DATE=$(date +%Y%m%d -d "$DATE +1 month")
    echo ${DATE}_${NEXT_DATE}
    DATE=$NEXT_DATE
done
