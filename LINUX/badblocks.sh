#!/bin/bash
BBDIR=$(pwd)
touch $BBDIR/`date '+%d%m%Y'`
today=`/usr/bin/storcli /c0 show badblocks | tail -n 5  | head -n 1  | sed 's/Bad Block Count //g' | sed s/' '//g `
echo $today > $BBDIR/`date '+%d%m%Y'`
yesterday=`cat $(date '+%d%m%Y' --date="(date) -1 day")`
if [[ $today -gt $yesterday ]]
then
echo "Наблюдается рост BAD BLOCKS на дисках !!! Вчера было $yesterday, сегодня стало $today" | mail -s "РОСТ ПЛОХИХ СЕКТОРОВ!!!" root
fi