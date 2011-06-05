#!/bin/bash

# send mails about scheduled dates
#
# for more informations visit:
#
#          http://binfalse.de

# looking forward how many days?
NUM_DAYS=7

# file with dates
CAL_FILE=/path/to/cal/file

SUBJECT="scheduled dates"
EMAIL="someone@somewhere.tld"

MESSAGE=$(/usr/bin/calendar -A $NUM_DAYS -f $CAL_FILE)

if [ -n "$MESSAGE" ]
then
	echo "$MESSAGE" | /usr/bin/mail -s "$SUBJECT" "$EMAIL"
fi
