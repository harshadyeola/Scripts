#!/bin/bash

# Author : Harshad Yeola
# This script freezes the environment for current wordpress setup 
# and reset the environment on next run.
# Usage :
# bash resetcron.sh [ init | reset | backup ]


throw_error() {
	echo $1 | tee -ai $LOG_PATH
	exit $2;
}

main(){

    # Initialize variables
    SITE_WEBROOT='/var/www/example.com'
    SITE_DB_NAME=$(grep DB_NAME ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_USER=$(grep DB_USER ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_PASS=$(grep DB_PASS ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_BACKUP_PATH="${SITE_WEBROOT}/reset-backup/example_com.sql"
    GIT_DIR="${SITE_WEBROOT}"
    LOG_PATH='/var/log/resetcron.log'


    init(){

        # Add .gitignore
        printf "*\n!htdocs/\n!htdocs/**\n!reset-backup/\n!reset-backup/example_com.sql" > ${SITE_WEBROOT}/.gitignore

        # Initialize git repo
        if [ ! -d ${GIT_DIR}/.git ]; then
            cd ${GIT_DIR};
            git init

            # take database backup
            if [ ! -f ${SITE_DB_BACKUP_PATH} ]; then 
                if [ ! -d "${SITE_WEBROOT}/reset-backup/" ]; then
                    mkdir -p "${SITE_WEBROOT}/reset-backup/"
                fi
                mysqldump -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} > ${SITE_DB_BACKUP_PATH} || throw_error "failed to take database backup" $?
            fi
            git add .
            git commit -am "[$(date)] : Initialized resetcron"
        else
            throw_error "already a git repo" $?
        fi
    }
    

    reset(){

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

    }

    backup(){

        # take latest database backup
        mysqldump -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} > ${SITE_DB_BACKUP_PATH} || throw_error "failed to take database backup" $?

        # commit database changes
        git commit -m "[$date] : database renewed"

        # commit other changes in webroot
        git commit -am "[$date] : webroot renewed"
    }   

    $1     
}

if [[  "$#" -gt 3 ]]; then
    exit 1
fi
if [[ "$1" == "init" || "$1" == "reset" || "$1" == "backup" ]]; then

    main $1
fi 
