#!/bin/bash

###############################
#
#   automatic backup script
#
#   written by Martin Scharm
#      see http://binfalse.de
#
###############################


# what to backup
TOBACKUP="/boot /etc /home /root /svn /var/mail /var/www"

# max fs usage in percent, we don't want to blow up the disc
MAX_FS_USAGE=75

# directory to store the backups
BACKUPDIR=/var/backups/mysystembackups

# identifier for the backup, controlling backup mechanisms:
#       daily full-backup
#               $(date +'%d-%m-%Y')
#       weekly full-backup
#               $(date +'%U-%Y')
#       monthly full-backup
#               $(date +'%m-%Y')
#       yearly full-backup
#               $(date +'%Y')
DATESTR=$(date +'%U-%Y')

# file to store the backup
BACKUPFILE=${BACKUPDIR}/${DATESTR}_backup_$(date +'%F_%H-%M-%S').tgz

# snapshot for incremental backup
SNAPSHOT=${BACKUPDIR}/${DATESTR}_snapshot

# log the output
LOG=${BACKUPDIR}/backup.log

# log the error
ERRLOG=${BACKUPDIR}/backup.err



################################################################################
# thats it... don't change anything below unless you know what you're doing... #
################################################################################

if [ $(/usr/bin/id -u) -ne 0 ]
then
    echo "only root can do backups!"
    exit 1
fi

[ -d ${BACKUPDIR} ] || mkdir -p ${BACKUPDIR}

if [ ! -d ${BACKUPDIR} ]
then
    echo "can't create ${BACKUPDIR}!" >> ${ERRLOG}
    exit 1
fi

fs_usage=$(/bin/df ${BACKUPDIR} | /bin/grep -v Filesystem | /usr/bin/awk '{sub (/%/, ""); print $5}')

if [ ${MAX_FS_USAGE} -lt ${fs_usage} ]
then
        echo "not enough free disk space! please clean up!" >> ${ERRLOG}
        exit 1
fi


/bin/tar --listed-incremental=${SNAPSHOT} --create --gzip --file=${BACKUPFILE} ${TOBACKUP} >> ${LOG} 2>> ${ERRLOG}
ret=$?

chmod 600 ${BACKUPFILE} ${SNAPSHOT}
chmod 644 ${LOG} ${ERRLOG}

exit ${ret}

