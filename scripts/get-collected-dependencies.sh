#! /bin/bash

# Input is something like this: NorthWestLondon/mean/monthly

AREA=$(echo $1 | cut -d '/' -f 1)
STAT=$(echo $1 | cut -d '/' -f 2)
PERIOD=$(echo $1 | cut -d '/' -f 3)

PERIOD_SCRIPT=scripts/${PERIOD}-intervals.sh
if [ ! -f $PERIOD_SCRIPT ]; then
    echo "no script $PERIOD_SCRIPT, exiting" >&2
    exit 1
fi

for INTERVAL in $(scripts/${PERIOD}-intervals.sh); do
    echo data/index_values/$AREA/$STAT/$INTERVAL.json
done
