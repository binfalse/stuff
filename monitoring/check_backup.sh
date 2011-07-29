#!/bin/bash
###################################
#
#     Check if there are pending Backups
#     written by Martin Scharm
#       see http://binfalse.de
#
#     tested with v8.60
#
###################################

source /usr/lib/nagios/plugins/utils.sh

#############
# ARGUMENTS:
#############

# maximum number of stored backups, if this value is exceeded we'll warn
MAX=${1}



#############
# CONFIG:
#############

# please take care of paths!!

# where are backups located
BACKUPDIR=/var/backups/sysbackups

# error log file
ERRLOG=${BACKUPDIR}/backup.err


################################################################################
# thats it... don't change anything below unless you know what you're doing... #
################################################################################

PENDING=$(/bin/ls ${BACKUPDIR} | /bin/grep snapshot | /usr/bin/wc -l)
ERRORS=0

crit=""
warn=""

if [ -f ${ERRLOG} ]
then
        ERRORS=$(/bin/cat ${ERRLOG} | /bin/grep -v "tar: Removing leading" | /usr/bin/wc -l)
else
        warn="${warn} error log not present. path correct?"
fi

if [ ${MAX} -lt ${PENDING} ]; then
        crit="${crit} please download and clean up!"
fi

if [ ${ERRORS} -gt 0 ]
then
        crit="${crit} please deal with errors!"
fi


if [ -n "${crit}" ]
then
        echo "${PENDING} backups pending... ${ERRORS} errors! ${crit} ${warn}"
        exit ${STATE_CRITICAL}
fi

if [ -n "${warn}" ]
then
        echo "${PENDING} backups pending... ${ERRORS} errors! ${crit} ${warn}"
        exit ${STATE_WARNING}
fi


echo "${PENDING} backups pending... ${ERRORS} errors. that's ok..."
exit ${STATE_OK}

