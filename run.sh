#!/bin/bash

ts=`date +%Y/%m/%d-%H:%M:%S`

echo "$ts - Removing inactive users or users without consent"

users=$(curl -s http://localhost:4567/api/users | jq '.users')
users_len=${#users[@]}
echo "$ts - Found $users_len users"

for row in $(echo "${users}" | jq -r '.[] | @base64'); do
  _jq() {
       echo ${row} | base64 --decode | jq -r ${1}
  }

	uid=$(_jq '.uid')
	userslug=$(_jq '.userslug')
	lastonline=$(_jq '.lastonline')
	joindate=$(_jq '.joindate')

  diff_lastonline=$((($(date +%s%N | cut -b1-13) - lastonline)/(60*60*24*1000)))
	diff_joindate=$((($(date +%s%N | cut -b1-13) - joindate)/(60*60*1000)))

  echo "$ts - Verifying if user with uid $uid has been inactive too long..."
  echo "$ts - User with uid $uid was last online: $diff_lastonline days ago"
  # Remove user if not active more than one year
  if [ $diff_lastonline -gt 365 ]
	then
		echo "$ts - Removing inactive user with uid $uid (not online for $diff days)"
		curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v2/users/$uid"
		echo ""
	fi

  echo "$ts - Verifying if user with uid $uid has approved gdpr consent..."
  echo "$ts - User with uid $uid joined: $diff_joindate hours ago"
  # Remove if user did not consent and joined more than one hour ago
	if [ $diff_joindate -gt 1 ]
	then
		gdpr_consent=$(curl -s -H "Authorization: Bearer $API_TOKEN" "http://localhost:4567/api/user/$userslug/consent" | jq '.gdpr_consent')
		if [ "false" = $gdpr_consent ]
		then
			echo "$ts - Removing user without gdpr consent with uid $uid"
      curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "http://localhost:4567/api/v2/users/$uid"
      echo ""
    else
      echo "$ts - User with uid $uid has approved gdpr consent"
		fi
	fi
done
