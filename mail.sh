#!/bin/bash

mail_file=$1 
from_unm=""
to_unm=""
from_passwd=""
to_passwd=""
from_imap=$2
to_imap=$3

fail_log="fail.log"

while read line
do
from_unm=$(echo $line | awk '{ print $1 }')
echo $from_unm
to_unm=$(echo $line | awk '{ print $3 }')
echo $to_unm

from_passwd=$(echo $line | awk '{ print $2 }')
echo $from_passwd

to_passwd=$(echo $line | awk '{ print $4 }')
echo $to_passwd

larch --from imap://$from_imap --from-user $from_unm \
 --from-pass $from_passwd \
 --to imap://$to_imap \
 --to-pass $to_passwd \
 --to-user $to_unm \
 --all >> larch.log || echo "failed to migrate mail from user $from_unm to $to_unm" >> $fail_log

done < $mail_file
