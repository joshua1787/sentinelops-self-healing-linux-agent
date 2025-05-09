# SentinelOps – AI-Powered Self-Healing Linux System

## Overview
SentinelOps is a lightweight, AI-augmented Linux agent that provides real-time self-healing, anomaly detection, Slack alerting, and OpenRouter-powered GPT explanations. It's designed for personal systems, DevOps environments, and small-scale production use.

---

## Features
- ✅ Disk usage monitoring and auto-log cleanup
- 🚨 Memory spike detection and safe process killing
- 🔄 Service health checks and auto-restart (e.g., cron, nginx)
- 📩 Slack webhook integration for alerts
- 🤖 OpenRouter GPT integration for log explanations
- 📊 Anomaly detection with Python + psutil
- 📈 Prometheus + Grafana dashboard support
- 🔁 Fully automated via `systemd` timers

---

## Project Structure
```
sentinelops-self-healing-linux-agent/
├── sentinel.sh                  # Main Bash script for self-healing
├── sentinel-metrics.py          # Python metrics agent with AI explanation
├── sentinel.service             # systemd service for bash agent
├── sentinel.timer               # systemd timer for bash agent
├── sentinel-metrics.service     # systemd service for metrics agent
├── sentinel-metrics.timer       # systemd timer for metrics agent
├── install.sh                   # One-click installer
├── etc/
│   ├── agent.conf               # Configuration file
│   └── whitelist.conf           # Whitelisted processes
├── logs/
│   ├── sentinel.log             # Main agent logs
│   └── sentinelops-metrics.log  # Metrics + anomaly logs
└── README.md
```

---

## Installation
```bash
git clone https://github.com/yourusername/sentinelops-self-healing-linux-agent.git
cd sentinelops-self-healing-linux-agent
chmod +x install.sh
sudo ./install.sh
```

---

## Configuration
Edit `/etc/sentinelops/agent.conf` to adjust:
- `DISK_USAGE_LIMIT`
- `MEMORY_THRESHOLD`
- `SERVICE_NAME`
- `ENABLE_SLACK`, `SLACK_WEBHOOK_URL`
- `EXPLAIN_LOGS`, `OPENROUTER_API_KEY`

---

## How It Works
- ⏱ Every 5 minutes, systemd runs `sentinel.sh` and `sentinel-metrics.py`
- 🔍 These agents check for disk/memory/service anomalies
- 🔧 Auto-remediation occurs based on config
- 📥 Alerts and explanations are sent to Slack and logs

---

## Monitoring Dashboard (Optional)
- `node_exporter` runs on port `:9100`
- Prometheus scrapes metrics using configured `prometheus.yml`
- Grafana visualizes data using provided dashboard JSON

---

## Requirements
- 🐧 Linux (Ubuntu/Debian preferred)
- 🐍 Python3, `psutil`, `jq`
- 🌐 Internet access for OpenRouter + Slack integration (optional)

---

## License
[MIT](https://opensource.org/licenses/MIT)

---

## Contributors
- Joshua  https://github.com/joshua1787
- Inspired by real-world SRE/DevOps best practices

---

## Coming Soon
- 📬 Email alerting
- 🖥 GUI dashboard
- 📟 System tray support

---

> 🔧 Built with love by **SentinelOps Labs** – Open-source AI-enhanced reliability tooling.
