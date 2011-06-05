#!/bin/bash

# for more informations visit:
#
#          https://binfalse.de

if [ $# -ne 1 ]
then
    echo "Usage: `basename $0` [ARCHIVE TO UNPACK]"
    exit 1
fi

if [ ! -f $1 ] || [ ! -r $1 ]
then
    echo "File $1 does not exists or is not readable"
    exit 1
fi



FILE=`echo $1 | tr '[A-Z]' '[a-z]'`

case "$FILE" in
    *.tar.gz)
        EXT=".tar.gz";
        CMD="tar -zxvf";
        CD="-C ";;
    *.tgz)
        EXT=".tgz";
        CMD="tar -zxvf";
        CD="-C ";;
    *.tar.bz2)
        EXT=".tar.bz2";
        CMD="tar -jxvf";
        CD="-C ";;
    *.tar.bzip2)
        EXT=".tar.bzip2";
        CMD="tar -jxvf";
        CD="-C ";;
    *.tar)
        EXT=".tar";
        CMD="tar -xvf";
        CD="-C ";;
    *.zip)
        EXT=".zip";
        CMD="unzip";
        CD="-d ";;
    *.bz2)
        EXT=".bz2";
        CMD="bunzip2 -d -k -v";
        CD="changeto";;
    *.gz)
        EXT=".gz";
        CMD="gunzip -d -v";
        CD="changeto";;
    *.lha)
        EXT=".lha";
        CMD="lha x";
        CD="w=";;
    *.ace)
        EXT=".ace";
        CMD="unace";
        CD="changeto";;
    *.rar)
        EXT=".rar";
        CMD="rar x";
        CD=" ";;
    *.cab)
        EXT=".cab";
        CMD="cabextract";
        CD="-d ";;
    *.xpi)
        EXT=".xpi";
        CMD="unzip";
        CD="-d ";;
    *.jar)
        EXT=".jar";
        CMD="jar xvf";
        CD="-C ";;
    *.deb)
        EXT=".deb";
        CMD="ar xvo";
        CD="changeto";;
    *.lzo)
        EXT=".lzo";
        CMD="lzop -x";
        CD="-p";;
    *)
        echo "Do not know that type of Archive!";
        exit 1;;
esac


DIR=`echo $FILE | perl -pe "s/$EXT$//"`


# existiert das Directory schon??
if [ -d $DIR ]
then
    echo -e "$DIR exists!\n\td - Delete it!\n\ta - apend Date/Time\n\tany other Input will Cancel!"
    read IN
    case "$IN" in
        d)
            rm -rf $DIR;;
        a)
            DIR=${DIR}_`date +"%F_%H-%M-%S"`;;
        *)
            echo "Aborted!"
            exit 1;;
    esac
fi

mkdir -p $DIR
if [ $? -ne 0 ]
then
    echo FAILED
    exit 1
fi

# unpack
echo "Extracting with '$CMD' to $DIR"


if [ "$CD" == "changeto" ]
then
    cd $DIR
    $CMD ../$1
    if [ $? -ne 0 ]
    then
        echo "FAILED"
        exit 1
    fi
else
    $CMD $1 $CD $DIR
    if [ $? -ne 0 ]
    then
        echo "FAILED"
        exit 1
    fi
fi

echo "Extracted Archive ;-)"


