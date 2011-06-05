#!/bin/bash
###################################
#
# Backup MySQL Databases
#   author: Martin Scharm
#
# for more informations visit:
#          http://binfalse.de
#
###################################

# MySQL credentials
MYSQL_USER="mrsmith"
MYSQL_PASS="mr.smiths.girlfriend"
MYSQL_HOST="localhost"

# where to write the backup
BACKUP_DIR="/backup/mysql"
NOW=$(date +"%Y-%m-%d_%H-%M")

# backup all databases in one file ?
ALL_DATABASES="yes"
# backup each database in a single file ?
EACH_DATABASE="yes"

# path to tools
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
GZIP="/bin/gzip"
MAIL="/usr/bin/mail"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# don't touch the following
# until you know what you're doing!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# should we backup all in one?
if [ "$ALL_DATABASES" == "yes" ]
then
	$MYSQLDUMP --all-databases -u ${MYSQL_USER} -h $MYSQL_HOST -p${MYSQL_PASS} | ${GZIP} -9 > "${BACKUP_DIR}/${NOW}_complete.sql.gz"
fi

# additionally backup each ?
if [ "$EACH_DATABASE" == "yes" ]
then
	DBS="$(${MYSQL} -u ${MYSQL_USER} -h ${MYSQL_HOST} -p${MYSQL_PASS} -Bse 'show databases')"
	for db in $DBS
	do
		[ "$db" == "information_schema" ] && continue
		$MYSQLDUMP -u ${MYSQL_USER} -h ${MYSQL_HOST} -p${MYSQL_PASS} ${db} | ${GZIP} -9 > "${BACKUP_DIR}/${NOW}_${db}.sql.gz"
	done
fi
