#!/bin/bash


# Author : Harshad Yeola
# This script fetches ssh key from github for username provided as argument 
# also append that to ssh authorized keys

function retrieve_key() {
        NAME=$1 && KEY="$(curl -s https://github.com/$NAME.keys)" && echo "$KEY" $NAME >> ~/.ssh/authorized_keys
}

retrieve_key $1
