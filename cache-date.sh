#!/bin/bash

SERVERPATH=http://ftp.mozilla.org/pub/mozilla.org/firefox/nightly
BRANCH=mozilla-central
LOCALCACHE=$(dirname $0)/cache

if [ $# -ne 1 ]
then
    echo "Expected one parameter." 1>&2
    exit 1
fi

DATE=$1

if ! date --date="$DATE" > /dev/null
then
    echo "Expected parameter to be a date" 1>&2
    exit 1
fi

YEAR=$(date +%Y --date="$DATE")
MONTH=$(date +%m --date="$DATE")
YMD=$(date +%F --date="$DATE")

MONTHLIST="$SERVERPATH/$YEAR/$MONTH"
wget -q -O - "$MONTHLIST/"  | grep "icons/folder.gif" | sed 's/.*<a href="\([^"]*\)".*/\1/' | grep "$BRANCH/$" | sed 's,/$,,' | grep "^$YMD" | while read BUILDDIR
do
    HOURLIST="$MONTHLIST/$BUILDDIR"
    wget -q -O - "$HOURLIST/" | grep '<img src="/icons/' | grep "<a href=" | sed 's/.*<a href="\([^"]*\)".*/\1/' | grep "\.txt$" | while read TXTFILE
    do
        TXTPATH="$HOURLIST/$TXTFILE"
        DEST="$LOCALCACHE/$BUILDDIR/$TXTFILE"
        mkdir -p $(dirname "$DEST")
        wget -q -O - "$TXTPATH" >| "$DEST"
    done
done
