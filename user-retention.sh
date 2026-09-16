#!/bin/bash
#
# User retention / GDPR cleanup for Datalandsbyen (NodeBB).
#
# Inactive users
# --------------
# A user who has not been online for MAX_OFFLINE is deleted, but only after a
# series of warning emails, sent WARNING_BEFORE[i] before the deletion date
# (6 weeks, 1 week and 1 day in production).
#
# The deletion date is fixed when the first warning is sent:
#   delete_at = max(lastonline + MAX_OFFLINE, now + WARNING_BEFORE[0])
# so a user who is already far past the limit (e.g. because this job has been
# inactive for a while) still gets the full notice period before the account
# is removed. If a later warning is sent late for the same reason, the
# deletion date is pushed so the user always gets at least WARNING_BEFORE[i]
# notice after that warning.
#
# State is kept per user in $STATE_DIR:
#   <uid>.warning<n>  - warning n sent, content: scheduled deletion (epoch ms)
#   <uid>.deleted     - deletion email sent and account deleted (or would have
#                       been, in test mode)
# The state is cleared as soon as the user logs in again.
#
# Users without consent
# ---------------------
# Users who have not accepted the GDPR consent within an hour of joining are
# deleted without warning.
#
# TEST_MODE=true shortens all periods, sends every email to TEST_EMAIL, uses a
# separate state directory and never actually deletes anyone.

FILES_DIR="${FILES_DIR:-/usr/src/app/files}"
TEMPLATE_DIR="${TEMPLATE_DIR:-/}"
SENDMAIL="${SENDMAIL:-/usr/sbin/sendmail}"
API_URL="${API_URL:-http://localhost:4567}"

HOUR_MS=$((60 * 60 * 1000))
DAY_MS=$((24 * HOUR_MS))

# Templates are mail-template-<name>.html in $TEMPLATE_DIR, in sending order.
WARNING_TEMPLATES=(delete-6weeks delete-7days delete-1days)

if [ "true" = "$TEST_MODE" ]; then
  MAX_OFFLINE=$((3 * DAY_MS))
  WARNING_BEFORE=($((2 * DAY_MS)) $((1 * DAY_MS)) $((6 * HOUR_MS)))
  STATE_DIR="$FILES_DIR/retention-test"
else
  MAX_OFFLINE=$((365 * DAY_MS))
  WARNING_BEFORE=($((42 * DAY_MS)) $((7 * DAY_MS)) $((1 * DAY_MS)))
  STATE_DIR="$FILES_DIR/retention"
fi

NOW_MS=$(( $(date +%s) * 1000 ))

log() {
  echo "$(date +%Y/%m/%d-%H:%M:%S) - $*"
}

# Format an epoch-ms timestamp as dd.mm.yyyy (GNU date first, BSD date as fallback).
format_date() {
  local sec=$(( $1 / 1000 ))
  date -d "@$sec" +%d.%m.%Y 2>/dev/null || date -r "$sec" +%d.%m.%Y
}

max() {
  if [ "$1" -ge "$2" ]; then echo "$1"; else echo "$2"; fi
}

# send_mail <template> <uid> <userslug> [<delete_at_ms>]
send_mail() {
  local template="$1" uid="$2" userslug="$3" delete_at="$4"
  local details email name mail delete_date=""

  details=$(curl -s -H "Authorization: Bearer $API_TOKEN" "$API_URL/api/v3/users/$uid?_uid=$TOKEN_UID" | jq -r '.response')
  email=$(echo "$details" | jq -r '.email // empty')
  name=$(echo "$details" | jq -r '.fullname // .username // empty')

  if [ -z "$email" ]; then
    log "User with uid $uid has no email address, cannot send $template"
    return 1
  fi

  if [ -n "$delete_at" ]; then
    delete_date=$(format_date "$delete_at")
  fi

  mail=$(cat "$TEMPLATE_DIR/mail-template-$template.html")
  mail="${mail//@@BASE_URL@@/$BASE_URL}"
  mail="${mail//@@UID@@/$uid}"
  mail="${mail//@@NAME@@/$name}"
  mail="${mail//@@USERSLUG@@/$userslug}"
  mail="${mail//@@EMAIL@@/$email}"
  mail="${mail//@@DELETE_DATE@@/$delete_date}"

  local recipient="$email"
  if [ "true" = "$TEST_MODE" ]; then
    recipient="$TEST_EMAIL"
  fi

  if echo "$mail" | "$SENDMAIL" "$recipient"; then
    log "Sent $template email for user with uid $uid to $recipient"
    return 0
  else
    log "Failed to send $template email for user with uid $uid to $recipient"
    return 1
  fi
}

delete_user() {
  local uid="$1"
  if [ "true" = "$TEST_MODE" ]; then
    log "TEST MODE: would have deleted user with uid $uid"
  else
    curl -s -H "Authorization: Bearer $API_TOKEN_WRITE" -X DELETE "$API_URL/api/v3/users/$uid/account?_uid=$TOKEN_UID"
    echo ""
  fi
}

process_inactive_user() {
  local uid="$1" userslug="$2" lastonline="$3"
  local deleted="$STATE_DIR/$uid.deleted"
  local offline=$((NOW_MS - lastonline))
  local days_offline=$((offline / DAY_MS))
  local n warning previous delete_at

  log "User with uid $uid was last online $days_offline days ago"

  if [ -f "$deleted" ]; then
    log "User with uid $uid has already been deleted"
    return
  fi

  # Not (yet) inactive long enough to be warned. Clear any state from an
  # earlier inactivity period; the user has been back since then.
  if [ "$offline" -lt $((MAX_OFFLINE - WARNING_BEFORE[0])) ]; then
    if ls "$STATE_DIR/$uid.warning"* >/dev/null 2>&1; then
      log "User with uid $uid has been online after being warned, cancelling scheduled deletion"
      rm -f "$STATE_DIR/$uid.warning"*
    fi
    return
  fi

  # Send the next warning that is due. The first warning fixes the deletion
  # date; later warnings may push it if they are sent late.
  for n in "${!WARNING_TEMPLATES[@]}"; do
    warning="$STATE_DIR/$uid.warning$((n + 1))"
    [ -f "$warning" ] && continue

    if [ "$n" -eq 0 ]; then
      delete_at=$(max $((lastonline + MAX_OFFLINE)) $((NOW_MS + WARNING_BEFORE[0])))
    else
      previous="$STATE_DIR/$uid.warning$n"
      delete_at=$(cat "$previous")
      if [ "$NOW_MS" -lt $((delete_at - WARNING_BEFORE[n])) ]; then
        log "User with uid $uid is scheduled for deletion on $(format_date "$delete_at"), warning $((n + 1)) in $(( (delete_at - WARNING_BEFORE[n] - NOW_MS) / HOUR_MS )) hours"
        return
      fi
      delete_at=$(max "$delete_at" $((NOW_MS + WARNING_BEFORE[n])))
    fi

    log "User with uid $uid is scheduled for deletion on $(format_date "$delete_at"), sending warning $((n + 1)) (${WARNING_TEMPLATES[n]})"
    if send_mail "${WARNING_TEMPLATES[n]}" "$uid" "$userslug" "$delete_at"; then
      echo "$delete_at" > "$warning"
    fi
    return
  done

  # All warnings sent: delete when the deletion date has passed.
  delete_at=$(cat "$STATE_DIR/$uid.warning${#WARNING_TEMPLATES[@]}")
  if [ "$NOW_MS" -ge "$delete_at" ] && [ "$offline" -gt "$MAX_OFFLINE" ]; then
    if send_mail "deleted" "$uid" "$userslug"; then
      log "Removing inactive user with uid $uid (not online for $days_offline days, first warned on $(format_date "$(cat "$STATE_DIR/$uid.warning1")"))"
      delete_user "$uid"
      touch "$deleted"
      rm -f "$STATE_DIR/$uid.warning"*
    fi
  else
    log "User with uid $uid is scheduled for deletion on $(format_date "$delete_at")"
  fi
}

process_consent() {
  local uid="$1" userslug="$2" joindate="$3"
  local hours_since_join=$(( (NOW_MS - joindate) / HOUR_MS ))
  local gdpr_consent

  if [ -f "$STATE_DIR/$uid.deleted" ]; then
    return
  fi

  log "User with uid $uid joined $hours_since_join hours ago"
  if [ "$hours_since_join" -ge 1 ]; then
    gdpr_consent=$(curl -s -H "Authorization: Bearer $API_TOKEN" "$API_URL/api/user/$userslug/consent" | jq -r '.gdpr_consent')
    if [ "false" = "$gdpr_consent" ]; then
      log "Removing user without gdpr consent with uid $uid"
      delete_user "$uid"
    else
      log "User with uid $uid has approved gdpr consent"
    fi
  fi
}

# ---------------------------------------------------------------------------

mkdir -p "$STATE_DIR"

if [ "true" = "$TEST_MODE" ]; then
  log "#### RUNNING IN TEST MODE ####"
fi
log "Removing inactive users or users without consent (delete after $((MAX_OFFLINE / DAY_MS)) days offline, warnings $((WARNING_BEFORE[0] / HOUR_MS))h, $((WARNING_BEFORE[1] / HOUR_MS))h and $((WARNING_BEFORE[2] / HOUR_MS))h before)"

current_page=1
page_count=1
while [ "$current_page" -le "$page_count" ]; do
  body=$(curl -s "$API_URL/api/users?page=${current_page}")
  page_count=$(echo "$body" | jq -r '.pagination.pageCount // empty')

  if ! [ "$page_count" -ge 1 ] 2>/dev/null; then
    log "Could not read user list from $API_URL/api/users (page $current_page), aborting"
    exit 1
  fi

  if [ "$current_page" -eq 1 ]; then
    log "Total number of users: $(echo "$body" | jq -r '.userCount')"
    log "Total number of pages: $page_count"
  fi
  log "Processing page $current_page of $page_count"

  while IFS=$'\t' read -r uid userslug joindate lastonline; do
    [ -z "$uid" ] && continue

    if [ -n "$TOKEN_UID" ] && [ "$uid" = "$TOKEN_UID" ]; then
      log "Skipping API user with uid $uid"
      continue
    fi

    if [ -z "$lastonline" ] || [ "$lastonline" = "null" ] || [ "$lastonline" -eq 0 ]; then
      lastonline="$joindate"
    fi

    process_inactive_user "$uid" "$userslug" "$lastonline"
    process_consent "$uid" "$userslug" "$joindate"
  done < <(echo "$body" | jq -r '.users[] | [.uid, .userslug, .joindate, .lastonline] | @tsv')

  current_page=$((current_page + 1))
done
