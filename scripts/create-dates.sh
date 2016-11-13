startdate=20050101
enddate=$1

curr="$startdate"
while true; do
    echo "$curr"
    [ ! "$curr" -eq "$enddate" ] || break
    curr=$( date +%Y%m%d --date "$curr +1 day" )
done
