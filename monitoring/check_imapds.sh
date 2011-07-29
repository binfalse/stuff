#!/bin/bash
###################################
#
#     check the number of running
#     imapd's, we had some trouble
#     with them, few days ago
#
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

REVISION=0.1
PROGNAME=`/usr/bin/basename $0`
PROGPATH=`echo $0 | /bin/sed -e 's,[\\/][^\\/][^\\/]*$,,'`

CONFIGFILE="/etc/courier/imapd-ssl"

source /usr/lib/nagios/plugins/utils.sh

usage ()
{
    echo "\
Nagios plugin to check the number of imap deamons

Usage:
  $PROGNAME --help
  $PROGNAME --version
"
}

help ()
{
	print_revision $PROGNAME $REVISION
	echo; usage; echo; support
}

while [ -n "$1" ]; do
    case "$1" in
	--help | -h)
	    help
	    exit $STATE_OK;;
	--version | -V)
	    print_revision $PROGNAME $REVISION
	    exit $STATE_OK;;
	*)
	    usage; exit $STATE_UNKNOWN;;
    esac
    shift
done

max=(`grep MAXDEAMONS $CONFIGFILE`)
IFS="="
max=(${max[0]})
max=${max[1]}

ist=`ps -ef | grep imapd | wc -l`

if [ $ist -gt $max ]; then
	echo "ERROR: "$ist" imapd laufen, max ist "$max"!"
	exit $STATE_CRITICAL
fi


if [ `expr $ist + 5` -gt $max ]; then
        echo "WARN: "$ist" imapd laufen, max ist "$max"!"
        exit $STATE_WARNING
fi


echo "OK! "$ist" imapd laufen, max ist "$max
exit $STATE_OK

