#!/usr/bin/env python3

import psutil
import datetime
import json
import os
import requests

# === Config ===
LOG_FILE = "/var/log/sentinelops-metrics.log"
ANOMALY_THRESHOLD = 30  # % jump compared to previous value
SLACK_ENABLED = os.getenv("ENABLE_SLACK", "false").lower() == "true"
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")
EXPLAIN_ENABLED = os.getenv("EXPLAIN_LOGS", "false").lower() == "true"
GPT_API_KEY = os.getenv("OPENROUTER_API_KEY")

# === Helper Functions ===
def timestamp():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def log_event(message):
    with open(LOG_FILE, "a") as f:
        f.write(f"{timestamp()} {message}\n")

def send_slack(message):
    if SLACK_ENABLED and SLACK_WEBHOOK_URL:
        payload = {"text": message}
        try:
            requests.post(SLACK_WEBHOOK_URL, json=payload)
        except Exception as e:
            log_event(f"Slack error: {e}")

def explain_log(message):
    if not (EXPLAIN_ENABLED and GPT_API_KEY):
        return
    headers = {
        "Authorization": f"Bearer {GPT_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://yourdomain.com",
        "X-Title": "SentinelOps"
    }
    payload = {
        "model": "openai/gpt-3.5-turbo",
        "messages": [
            {"role": "system", "content": "You are a Linux monitoring assistant. Explain anomalies clearly."},
            {"role": "user", "content": message}
        ]
    }
    try:
        res = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, json=payload)
        if res.ok:
            content = res.json()['choices'][0]['message']['content']
            log_event(f"💬 AI Explanation: {content}")
            send_slack(f"💬 *AI Explanation:* {content}")
    except Exception as e:
        log_event(f"GPT error: {e}")

# === Main Logic ===
def collect_metrics():
    return {
        "cpu": psutil.cpu_percent(),
        "memory": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage('/').percent
    }

def detect_anomalies(curr, prev):
    alerts = []
    for key in curr:
        delta = abs(curr[key] - prev.get(key, 0))
        if delta > ANOMALY_THRESHOLD:
            alerts.append(f"⚠️ Sudden {key.upper()} jump: {curr[key]}% (Δ {delta:.1f}%)")
    return alerts

def main():
    curr = collect_metrics()
    prev = {}
    if os.path.exists("/tmp/sentinel-last.json"):
        with open("/tmp/sentinel-last.json", "r") as f:
            prev = json.load(f)
    with open("/tmp/sentinel-last.json", "w") as f:
        json.dump(curr, f)
    log_event(f"📊 Metrics: {curr}")
    alerts = detect_anomalies(curr, prev)
    for alert in alerts:
        log_event(alert)
        send_slack(alert)
        explain_log(alert)

if __name__ == "__main__":
    main()
