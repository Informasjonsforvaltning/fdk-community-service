#!/bin/bash

FILES_DIR="/usr/src/app/files"

sendUserDeletedEmail() {
  uid=$1
  flagFile="$FILES_DIR/mail/deleted-$uid"

  mkdir -p "$FILES_DIR/mail"

  if [ ! -f "$flagFile" ]; then
    echo "$ts - Sending deleted email to user with uid $uid"

    userslug=$2
    name=$3
    email=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug" | jq '.email')

    mail=$(cat /mail-template-deleted.html)
    mail="${mail//@@BASE_URL@@/$BASE_URL}"
    mail="${mail//@@UID@@/$uid}"
    mail="${mail//@@NAME@@/$name}"
    mail="${mail//@@USERSLUG@@/$userslug}"
    mail="${mail//@@EMAIL@@/$email}"

    if [ "true" = "$TEST_MODE" ];
    then
      echo "$mail" | /usr/sbin/sendmail $TEST_EMAIL
    else
      echo "$mail" | /usr/sbin/sendmail $email
      touch $flagFile
    fi
  fi
}

sendDeleteUserInXDaysEmail() {
  uid=$1
  
  echo "$ts - Sending notification email to user with uid $uid"

  userslug=$2
  name=$3
  email=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug" | jq '.email')

  mail=$(cat /mail-template-delete-7days.html)
  mail="${mail//@@BASE_URL@@/$BASE_URL}"
  mail="${mail//@@UID@@/$uid}"
  mail="${mail//@@NAME@@/$name}"
  mail="${mail//@@USERSLUG@@/$userslug}"
  mail="${mail//@@EMAIL@@/$email}"

  if [ "true" = "$TEST_MODE" ];
  then
    echo "$mail" | /usr/sbin/sendmail $TEST_EMAIL
  else
    echo "$mail" | /usr/sbin/sendmail $email
  fi
}

ts=`date +%Y/%m/%d-%H:%M:%S`


if [ "true" = "$TEST_MODE" ];
then
  echo "$ts - #### RUNNING IN TEST MODE ####"
fi
echo "$ts - Removing inactive users or users without consent"

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
    userslug=$(_jq '.userslug')
    fullname=$(_jq '.fullname')
    lastonline=$(_jq '.lastonline')
    joindate=$(_jq '.joindate')
    lastonline=$(_jq '.lastonline')

    notifyfile="$FILES_DIR/mail/delete-notify-$uid"
    notifydate=$(date +%s%N | cut -b1-13)

    if [ "true" = "$TEST_MODE" ];
    then
      notifyfile="$FILES_DIR/mail/delete-notify-$uid-test"
    fi
    
    if [ -f "$notifyfile" ]; 
    then
      notifydate=$(cat "$notifyfile")
    fi

    diff_lastonline=$((($(date +%s%N | cut -b1-13) - lastonline)/(60*60*24*1000)))
    diff_joindate=$((($(date +%s%N | cut -b1-13) - joindate)/(60*60*1000)))
    diff_notify=$((($(date +%s%N | cut -b1-13) - notifydate)/(60*60*24*1000)))

    echo "$ts - Verifying if user with uid $uid has been inactive too long..."
    echo "$ts - User with uid $uid was last online: $diff_lastonline days ago"
    # Remove user if not active more than one year and is 7 days after notification
    if [ $diff_lastonline -gt $max_days_offline ];
    then
      if [ -f "$notifyfile" ] && [ $diff_notify -ge $notify_days ];
      then
        echo "$ts - Removing inactive user with uid $uid (not online for $diff_lastonline days and notified $diff_notify days ago)"
        if [ "true" != "$TEST_MODE" ];
        then
          curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v3/users/$uid/account?_uid=$TOKEN_UID"
          echo ""
        fi

        sendUserDeletedEmail "$uid" "$userslug" "$fullname"
      else
        if [ ! -f "$notifyfile" ];
        then
          echo "$ts - User with uid $uid has not been notified yet. Not removing user."
        else
          remaining_days=$((notify_days - diff_notify))
          echo "$ts - Notification for user with uid $uid sent $diff_notify days ago. Deleting user in $remaining_days days."
        fi        
      fi      
    fi

    # Send email if users are going to removed in exactly 7 days
    if [ $diff_lastonline -ge $((max_days_offline - notify_days)) ];
    then
      # If user has not been notified before, send a notification
      if [ ! -f "$notifyfile" ];
      then
        echo "$(date +%s%N | cut -b1-13)" > $notifyfile
        sendDeleteUserInXDaysEmail "$uid" "$userslug" "$fullname"
      else
        # If use has been notified before, send a notification again of last notification was more than 
        # 365 days ago
        if [ $diff_notify -ge $((notify_days + max_days_offline)) ];
        then
          echo "$(date +%s%N | cut -b1-13)" > $notifyfile
          sendDeleteUserInXDaysEmail "$uid" "$userslug" "$fullname"
        fi
      fi 
    fi

    echo "$ts - Verifying if user with uid $uid has approved gdpr consent..."
    echo "$ts - User with uid $uid joined: $diff_joindate hours ago"
    # Remove if user did not consent and joined more than one hour ago
    if [ $diff_joindate -ge 1 ];
    then
      gdpr_consent=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug/consent" | jq '.gdpr_consent')
      if [ "false" = "$gdpr_consent" ];
      then
        echo "$ts - Removing user without gdpr consent with uid $uid"
        if [ "true" != "$TEST_MODE" ];
        then
          curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v3/users/$uid/account?_uid=$TOKEN_UID"
          echo ""
        fi
      else
        echo "$ts - User with uid $uid has approved gdpr consent"
      fi
    fi
  done

  current_page=$((current_page+1))
done


