#!/bin/bash

# for more informations visit:
#
#          https://binfalse.de

if [ $# -lt 1 ]
then
    echo "USAGE: $0 MEDIATHEKFILES"
    exit 1
fi

for i in $*
do
    echo "DOWNLOAD: $i"
    URL=`/bin/cat $i | /bin/grep href | /bin/sed 's/^.*href=\"\(.\+\?\)\".*$/\1/i'`
    FILE=`echo $URL | sed 's/^.*\///'`

    if [ -z $URL -o -z $FILE ]
    then
        echo "couldn't get data... found following:"
        echo "URL: $URL"
        echo "FILE: $FILE"
        exit 2
    fi

    /usr/bin/mplayer -dumpstream "$URL" -dumpfile "$FILE"
done

