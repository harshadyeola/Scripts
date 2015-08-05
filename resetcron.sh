#!/bin/bash

# Author : Harshad Yeola
# This script freezes the environment for current wordpress setup 
# and reset the environment on next run.
# Usage :
# bash resetcron.sh [ init | reset | backup ]


throw_error() {
	echo "[$(date)] : $1" | tee -ai $LOG_PATH
	exit $2;
}

main(){

    # Initialize variables
    SITE_WEBROOT='/var/www/example.com'
    SITE_DB_NAME=$(grep DB_NAME ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_USER=$(grep DB_USER ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_PASS=$(grep DB_PASS ${SITE_WEBROOT}/wp-config.php | cut -d "'" -f 4)
    SITE_DB_BACKUP_PATH="resetcron/example_com.sql"
    GIT_DIR="${SITE_WEBROOT}"
    LOG_PATH='/var/log/resetcron.log'


    init(){

        # Add .gitignore
        printf "*\n!htdocs/\n!htdocs/**\n!resetcron/\n!resetcron/example_com.sql" > ${SITE_WEBROOT}/.gitignore

        # Initialize git repo
        if [ ! -d ${GIT_DIR}/.git ]; then
            cd ${GIT_DIR};
            git init

            # take database backup
            if [ ! -f ${SITE_WEBROOT}/${SITE_DB_BACKUP_PATH} ]; then 
                if [ ! -d "${SITE_WEBROOT}/resetcron/" ]; then
                    mkdir -p "${SITE_WEBROOT}/resetcron/"
                fi
                su -c "mysqldump -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} > ${SITE_WEBROOT}/${SITE_DB_BACKUP_PATH}" - www-data || throw_error "failed to take database backup" $?
            fi
            su -c "git add ." - www-data
            git commit -am "[$(date)] : Initialized resetcron"
        else
            throw_error "already a git repo" $?
        fi
    }
    

    reset(){

        # START RESETING
        cd ${GIT_DIR}

        ## restore database 
        if [ -f ${SITE_DB_BACKUP_PATH} ]; then
            cat ${SITE_DB_BACKUP_PATH} | mysql -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} 2>>$LOG_PATH  || throw_error "restore database failed" $? 
        else
            throw_error "$SITE_DB_BACKUP_PATH not found" 1;
        fi

        ## reset filesystem
        if [ -d ${GIT_DIR}/.git ]; then
            cd ${GIT_DIR};
            git reset HEAD --hard && git clean -fd &>>$LOG_PATH || throw_error "git reset failed" $?;
        else 
            throw_error "${GIT_DIR}/.git not found" 2;
        fi

    }

    backup(){

        cd ${GIT_DIR}

        # take latest database backup
        mysqldump -u ${SITE_DB_USER} -p${SITE_DB_PASS} ${SITE_DB_NAME} > ${SITE_DB_BACKUP_PATH} || throw_error "failed to take database backup" $?

        # commit database changes
        git commit -m "[$(date)] : database renewed" ${SITE_DB_BACKUP_PATH} || "Unable to commit database changes" $?

        # commit other changes in webroot
        git add -A && git commit -am "[$(date)] : webroot renewed" || throw_error "Unable to commit webroot changes" $?
    }   

    $1 
}

if [[  "$#" -gt 3 ]]; then
    exit 1
fi
if [[ "$1" == "init" || "$1" == "reset" || "$1" == "backup" ]]; then

    main $1
fi 
