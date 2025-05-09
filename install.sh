#!/bin/bash

# === Create directories ===
sudo mkdir -p /opt/sentinelops
sudo mkdir -p /etc/sentinelops
sudo mkdir -p /var/log

# === Copy files ===
sudo cp sentinel.sh /opt/sentinelops/
sudo cp sentinel-metrics.py /opt/sentinelops/
sudo cp etc/agent.conf /etc/sentinelops/
sudo cp etc/whitelist.conf /etc/sentinelops/
sudo touch /var/log/sentinel.log /var/log/sentinelops-metrics.log
sudo chmod 666 /var/log/sentinel.log /var/log/sentinelops-metrics.log

# === systemd setup ===
sudo cp sentinel.service /etc/systemd/system/
sudo cp sentinel.timer /etc/systemd/system/
sudo cp sentinel-metrics.service /etc/systemd/system/
sudo cp sentinel-metrics.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now sentinel.timer
sudo systemctl enable --now sentinel-metrics.timer

# === Create Python venv & install psutil ===
sudo apt install -y python3-venv
python3 -m venv /opt/sentinelops/venv
source /opt/sentinelops/venv/bin/activate
pip install psutil
deactivate

echo "✅ SentinelOps installed and running via systemd timers."
    