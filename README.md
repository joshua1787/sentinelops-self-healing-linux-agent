SentinelOps — AI-Powered Self-Healing Linux Monitoring Agent



SentinelOps is an advanced AI-powered self-healing Linux agent designed to proactively monitor system health, detect anomalies in real-time, and take automated corrective actions. Integrated with GPT-based log explanations and Slack alerting, this system ensures transparency, reliability, and intelligent observability.

💡 Why SentinelOps?

While freelancing as a DevOps engineer, I encountered repeated production issues such as service crashes, high CPU spikes, and disk fill-ups. These required manual intervention every time, leading to stress and time loss. I built SentinelOps to:

Automatically detect and fix critical Linux issues

Explain anomalies in natural language using GPT

Notify teams instantly via Slack

Enhance production resilience with minimum human touch

🎓 Key Features

✅ System Monitoring (CPU, Memory, Disk, Service uptime)

⚙️ Self-Healing Scripts for common failures

🧠 GPT-based AI Explanations for log events

📢 Slack Alerts for real-time incident reporting

🌍 Grafana Dashboard (via Prometheus + Node Exporter)

🔧 Architecture

Linux Host
  └── sentinel.sh (Agent)
        └── Checks CPU, Memory, Disk, Service
              └── Triggers Healing Scripts + Logs to File
                    └── (Optional) Sends Slack Alerts
                          └── (Optional) Explains via GPT (OpenRouter/OpenAI)

  └── sentinel-metrics.py
        └── Periodic Metrics Logger (logs JSON + detects spikes)

Prometheus + Node Exporter + Grafana for Dashboard Visualization

⚡ Technologies Used

Bash: SentinelOps core logic and healing actions

Python: Metrics anomaly detection + log explanation

Prometheus & Grafana: Observability stack

Node Exporter: Linux metrics

Slack API: Real-time incident alerts

OpenRouter GPT: AI-driven explanations

📅 Real-World Use Case

Used on a cloud-hosted Linux VPS to:

Auto-restart failed services like cron, nginx, etc.

Cleanup disk when usage > 90%

Alert team on Slack and explain causes using AI

Log all metrics to /var/log/sentinelops-metrics.log

🚀 Quick Start

1. Clone this Repo

git clone https://github.com/yourusername/sentinelops
cd sentinelops

2. Configure Agent

Edit the config file:

sudo vim /etc/sentinelops/agent.conf

3. Start Agent

sudo bash /opt/sentinelops/sentinel.sh

4. Setup Python Metrics Logger

python3 -m venv /opt/sentinelops/venv
source /opt/sentinelops/venv/bin/activate
pip install -r requirements.txt

Then schedule sentinel-metrics.py using systemd timer.

5. Enable Dashboard

Run Prometheus + Node Exporter

Import Grafana dashboard JSON (included)

📊 Grafana Dashboard

Visualizes:

CPU, Memory, Disk Usage

Realtime Log Insights from sentinelops-metrics.log

🌟 Benefits

Reduces downtime through automated healing

Boosts observability with Prometheus + Grafana

Adds intelligence with GPT log summaries

Improves team response with Slack alerts

🚪 For Production Use

Run as a systemd service

Secure API keys via env variables or vault

Tune thresholds in agent.conf

🎉 Credits

Developed by @joshua1787
Inspired by real-world DevOps pain and the desire to automate everything.

☕ Support

If you found this helpful, feel free to star the repo and share on LinkedIn ❤️

📅 License

MIT License. Free to use and modify.

"Automate like your future depends on it. Because it does."

