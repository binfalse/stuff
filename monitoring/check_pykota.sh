#!/bin/bash
###################################
#
#     check if pykota is available.
#     especially helpful if somebody
#     updated python...
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

source /usr/lib/nagios/plugins/utils.sh

# nagios should be able to sudo on /usr/bin/pykotme
sudo /usr/bin/pykotme > /dev/null 2>&1

if [ $? -ne 0 ] 
then
	echo -e 'ERROR WITH PYKOTA!! Please check it'
	exit $STATE_CRITICAL
else
	echo -e 'PYKOTA-check ok!'
	exit $STATE_OK
fi

