#!/bin/bash

FILES_DIR="/usr/src/app/files"

sendUserDeletedEmail() {
  uid=$1
  flagFile="$FILES_DIR/mail/deleted-$uid"

  mkdir -p "$FILES_DIR/mail"

  if [ ! -f "$flagFile" ]; then
    echo "$ts - Sending email to user with uid $uid"

    userslug=$2
    name=$3
    email=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug" | jq '.email')

    mail=$(cat /mail-template-deleted.html)
    mail="${mail/@@BASE_URL@@/$BASE_URL}"
    mail="${mail/@@UID@@/$uid}"
    mail="${mail/@@NAME@@/$name}"

    if [ "true" = "$TEST_MODE" ];
    then
      mail="${mail/@@EMAIL@@/$TEST_EMAIL}"
      echo $mail | /usr/sbin/sendmail -t
    else
      mail="${mail/@@EMAIL@@/$email}"
      echo $mail | /usr/sbin/sendmail -t
      touch $flagFile
    fi
  fi
}

sendDeleteUserInXDaysEmail() {
  uid=$1
  flagFile="$FILES_DIR/mail/delete-10days-$uid"

  mkdir -p "$FILES_DIR/mail"

  if [ ! -f "$flagFile" ]; then
    echo "$ts - Sending email to user with uid $uid"

    userslug=$2
    name=$3
    email=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug" | jq '.email')

    mail=$(cat /mail-template-delete-7days.html)
    mail="${mail/@@BASE_URL@@/$BASE_URL}"
    mail="${mail/@@UID@@/$uid}"
    mail="${mail/@@NAME@@/$name}"

    if [ "true" = "$TEST_MODE" ];
    then
      mail="${mail/@@EMAIL@@/$TEST_EMAIL}"
      echo $mail | /usr/sbin/sendmail -t
    else
      mail="${mail/@@EMAIL@@/$email}"
      echo $mail | /usr/sbin/sendmail -t
      touch $flagFile
    fi
  fi
}

ts=`date +%Y/%m/%d-%H:%M:%S`


if [ "true" = "$TEST_MODE" ];
then
  echo "$ts - #### RUNNING IN TEST MODE ####"
fi
echo "$ts - Removing inactive users or users without consent"

users=$(curl -s http://localhost:4567/api/users | jq '.users')
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
	displayname=$(_jq '.displayname')
	lastonline=$(_jq '.lastonline')
	joindate=$(_jq '.joindate')

  diff_lastonline=$((($(date +%s%N | cut -b1-13) - lastonline)/(60*60*24*1000)))
	diff_joindate=$((($(date +%s%N | cut -b1-13) - joindate)/(60*60*1000)))

  echo "$ts - Verifying if user with uid $uid has been inactive too long..."
  echo "$ts - User with uid $uid was last online: $diff_lastonline days ago"
  # Remove user if not active more than one year
  if [ $diff_lastonline -gt $max_days_offline ];
	then
		echo "$ts - Removing inactive user with uid $uid (not online for $diff_lastonline days)"
		if [ "true" != "$TEST_MODE" ];
		then
      curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v2/users/$uid"
      echo ""
    fi

		sendUserDeletedEmail "$uid" "$userslug" "$displayname"
	fi

	# Send email if users are going to removed in exactly 10 days
	if [ $diff_lastonline -ge $((max_days_offline - notify_days)) ];
	then
	  sendDeleteUserInXDaysEmail "$uid" "$userslug" "$displayname"
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
        curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v2/users/$uid"
        echo ""
      fi
    else
      echo "$ts - User with uid $uid has approved gdpr consent"
		fi
	fi
done
