#!/bin/bash

# Author : Harshad Yeola
# This scripts is intended to be used as hook to sync repositories on server.


declare -A repos
declare -A branch

LOG="/var/log/hooks.log"

function error()
{
    echo -e "[ `date` ] failed ==> $(tput setaf 1)$@$(tput sgr0)" | tee -ai $LOG
    exit $2
}

function echo_output()
{
    echo -e "[ `date` ] success ==> $(tput setaf 4)$@$(tput sgr0)" | tee -ai $LOG
}



# define repo path and branch

# etc-config repo
repos['etc-config']='/etc'
branch['etc-config']='master'

# example-com-wp-composer repo
repos['example-com-wp-composer']='/var/www/wp.example.com'
branch['example-com-wp-composer']='master'


# repos['etc-config']="/home/harshad/Github/easyengine"
# branch['etc-config']='feature/plugin'


for repo in ${!repos[@]}; do
    path=${repos[$repo]}
    git_branch=${branch[$repo]}

    current_branch=$(cd $path && git rev-parse --abbrev-ref HEAD)

    if [ "$current_branch" == "$git_branch" ]; then

        echo_output "Fetching $repo commits at $path with branch $git_branch "
        cd $path &>>$LOG || error "cd $path" $?
        git reset --hard HEAD  &>>$LOG || error "git reset --hard HEAD" $?
        git pull origin ${git_branch} &>>$LOG || error "git pull origin ${git_branch}" $?

        if [ "$path" == "/etc" ]; then
            service nginx reload &>>$LOG || error "service nginx reload" $?
            service php5-fpm reload &&>>$LOG || error "service php5-fpm reload" $?
            service mysql reload &&>>$LOG || error "service mysql reload" $?
        fi
    fi
done
