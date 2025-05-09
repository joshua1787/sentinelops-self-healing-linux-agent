#!/bin/bash

# SentinelOps Bash Self-Healing Agent

LOG_FILE="/var/log/sentinel.log"
CONFIG_FILE="/etc/sentinelops/agent.conf"
WHITELIST_FILE="/etc/sentinelops/whitelist.conf"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Load configuration
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
: "${DISK_USAGE_LIMIT:=90}"
: "${MEMORY_THRESHOLD:=90.0}"
: "${SERVICE_NAME:=cron}"
: "${ENABLE_SLACK:=false}"
: "${EXPLAIN_LOGS:=false}"

# Load whitelist
WHITELIST=()
if [ -f "$WHITELIST_FILE" ]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    WHITELIST+=("$line")
  done < "$WHITELIST_FILE"
fi

send_slack_alert() {
  if [ "$ENABLE_SLACK" = true ] && [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -s -X POST -H 'Content-type: application/json' \
    --data "{\"text\": \"$1\"}" "$SLACK_WEBHOOK_URL" > /dev/null
  fi
}

explain_log() {
  if [ "$EXPLAIN_LOGS" = true ] && [ -n "$OPENROUTER_API_KEY" ]; then
    RESPONSE=$(curl -s https://openrouter.ai/api/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENROUTER_API_KEY" \
      -H "HTTP-Referer: https://yourdomain.com" \
      -H "X-Title: SentinelOps" \
      -d "{
        \"model\": \"openai/gpt-3.5-turbo\",
        \"messages\": [
          {\"role\": \"system\", \"content\": \"Explain this Linux log entry simply.\"},
          {\"role\": \"user\", \"content\": \"$1\"}
        ]
      }")
    echo "$(timestamp) 📦 Raw GPT Response: $RESPONSE" >> $LOG_FILE
    EXPLANATION=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')
    echo "$(timestamp) 💬 AI Explanation: $EXPLANATION" >> $LOG_FILE
  fi
}

check_disk() {
  USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  if [ "$USAGE" -gt "$DISK_USAGE_LIMIT" ]; then
    MSG="🔴 Disk usage high ($USAGE%)"
    echo "$(timestamp) $MSG" >> $LOG_FILE
    explain_log "$MSG"
    send_slack_alert "$MSG"
    find /var/log -name "*.log" -mtime +7 -exec rm -f {} \;
    echo "$(timestamp) ✅ Log cleanup completed." >> $LOG_FILE
  else
    echo "$(timestamp) ✅ Disk usage OK ($USAGE%)" >> $LOG_FILE
  fi
}

check_service() {
  if ! systemctl is-active --quiet $SERVICE_NAME; then
    echo "$(timestamp) 🔴 $SERVICE_NAME down. Restarting..." >> $LOG_FILE
    systemctl restart $SERVICE_NAME
    if systemctl is-active --quiet $SERVICE_NAME; then
      MSG="🔄 $SERVICE_NAME restarted."
      echo "$(timestamp) ✅ $MSG" >> $LOG_FILE
      explain_log "$MSG"
      send_slack_alert "$MSG"
    else
      MSG="❌ Failed to restart $SERVICE_NAME"
      echo "$(timestamp) $MSG" >> $LOG_FILE
      explain_log "$MSG"
      send_slack_alert "$MSG"
    fi
  else
    echo "$(timestamp) ✅ $SERVICE_NAME is running." >> $LOG_FILE
  fi
}

kill_memory_hog() {
  PID=$(ps -eo pid,%mem,comm --sort=-%mem | awk 'NR==2 {print $1}')
  MEM=$(ps -p $PID -o %mem= | tr -d ' ')
  CMD=$(ps -p $PID -o comm=)

  for safe in "${WHITELIST[@]}"; do
    if [[ "$CMD" == "$safe" ]]; then
      echo "$(timestamp) ⚠ $CMD (PID $PID) is whitelisted." >> $LOG_FILE
      return
    fi
  done

  if (( $(echo "$MEM > $MEMORY_THRESHOLD" | bc -l) )); then
    sleep 60
    NEWMEM=$(ps -p $PID -o %mem= | tr -d ' ')
    if (( $(echo "$NEWMEM > $MEMORY_THRESHOLD" | bc -l) )); then
      MSG="💀 Killed $CMD (PID $PID) using ${NEWMEM}% memory"
      echo "$(timestamp) $MSG" >> $LOG_FILE
      kill -9 $PID
      explain_log "$MSG"
      send_slack_alert "$MSG"
    fi
  else
    echo "$(timestamp) ✅ Memory usage OK (${MEM}%)" >> $LOG_FILE
  fi
}

check_disk
check_service
kill_memory_hog

LOG_LINE="🔴 Simulated disk failure for GPT test"
echo "$(timestamp) $LOG_LINE" >> $LOG_FILE
explain_log "$LOG_LINE"
