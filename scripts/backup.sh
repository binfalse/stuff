#!/bin/bash

# for more informations visit:
#
#          https://binfalse.de

if [ $# -ne 1 ]
then
    echo "Usage: `basename $0` [FILE/DIR TO BACKUP]"
    exit 1
fi

if [ ! -r $1 ]
then
    echo "$1 is not readable"
    exit 1
fi

DATE=`date +"%F_%H-%M-%S"`
BACKUP=$1_$DATE

if [ ! -d $1 ]
then
    cp $1 $BACKUP
else
    BACKUP=$BACKUP.tgz
    tar czf $BACKUP $1
fi

if [ $? -eq 0 ]
then 
    echo "DONE! BackUp to File: $BACKUP"
    exit 0
else 
    echo "FAILED!!"
    exit 1
fi  

