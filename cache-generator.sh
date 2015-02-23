#!/bin/bash


ERROR_LOG=/var/log/cache-generator.log

URI=$1

function log()
{
echo -e "[ `date` ] $(tput setaf 4)$@$(tput sgr0)" &>> $ERROR_LOG
exit $2
}


curl -I ${URI} &>> $ERROR_LOG & log "Caching ${URI}" $!
