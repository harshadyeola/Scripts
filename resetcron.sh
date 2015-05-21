#!/bin/bash

# Author : Harshad Yeola
# This script freezes the environment for current wordpress setup 
# and reset the environment on next run.


# Initialize variables
SITE_WEBROOT='/var/www/test.com'
SITE_DB_NAME=$(grep DB_NAME ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
SITE_DB_USER=$(grep DB_USER ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
SITE_DB_PASS=$(grep DB_PASS ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
SITE_DB_BACKUP_PATH="${SITE_WEBROOT}/reset-backup/test_com.sql"
GIT_DIR="${SITE_WEBROOT}/htdocs/wp-content/"
LOG_PATH='/var/log/resetcron.log'



throw_error() {
	echo $1 | tee -ai $LOG_PATH
	exit $2;
}


# Initialize 
if [ ! -d ${GIT_DIR}.git ]; then
    cd ${GIT_DIR};
    git init && git add . && git commit -m "freeze commit" || throw_error "failed to initialize reset env" $?
fi

# take database backup
if [ ! -f ${SITE_DB_BACKUP_PATH} ]; then 
    mysqldump -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} > ${SITE_DB_BACKUP_PATH} || throw_error "failed to take database backup" $?
fi


# START RESETING

## restore database 
if [ -f ${SITE_DB_BACKUP_PATH} ]; then
	cat ${SITE_DB_BACKUP_PATH} | mysql -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} 2>>$LOG_PATH  || throw_error "restore database failed" $? 
else
	throw_error "$SITE_DB_BACKUP_PATH not found" 1;
fi

## reset filesystem
if [ -d ${GIT_DIR} ]; then
	cd ${GIT_DIR};
	git reset HEAD --hard && git clean -fd  2>&1>>$LOG_PATH || throw_error "git reset failed" $?;
else 
	throw_error "${GIT_DIR} not found" 2;
fi
