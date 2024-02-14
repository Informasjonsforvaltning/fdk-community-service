#!/bin/bash

FILES_DIR="/usr/src/app/files"

printEmail() {
  uid="$1"
  details=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/v3/users/$uid?_uid=$TOKEN_UID" | jq -r '.response')
  email=$(echo "${details}" | jq -r '.email')
  echo "$email\n"
}

ts=`date +%Y/%m/%d-%H:%M:%S`
current_page=1
page_count=1
while [ $current_page -le $page_count ]; do
  body=$(curl -s "http://localhost:4567/api/users?page=${current_page}" | base64)
  users=$(echo "${body}" | base64 --decode | jq '.users')
  pagination=$(echo "${body}" | base64 --decode | jq '.pagination')
  page_count=$(echo "${pagination}" | jq -r '.pageCount')

  for row in $(echo "${users}" | jq -r '.[] | @base64'); do
    _jq() {
         echo ${row} | base64 --decode | jq -r ${1}
    }

    max_days_offline=365
    notify_days=7
    if [ "true" = "$TEST_MODE" ];
    then
      max_days_offline=3
      notify_days=1
    fi

    uid=$(_jq '.uid')
    lastonline=$(_jq '.lastonline')

    notifyfile="$FILES_DIR/mail/delete-notify-$uid"
    
    if [ "true" = "$TEST_MODE" ];
    then
      notifyfile="$FILES_DIR/mail/delete-notify-$uid-test"
    fi
    
    diff_lastonline=$((($(date +%s%N | cut -b1-13) - lastonline)/(60*60*24*1000)))
        
    if [ $diff_lastonline -gt $max_days_offline ];
    then
      if [ -f "$notifyfile" ];
      then       
        diff_notify=$((($(date +%s%N | cut -b1-13) - $(cat "$notifyfile"))/(60*60*24*1000)))
        if [ $diff_notify -ge 5 ];
        then
          printEmail $uid          
        fi
      fi        
    fi
  done

  current_page=$((current_page+1))
done


