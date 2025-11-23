#!/bin/bash
set -euo pipefail

# =========================
# Cài dependencies
# =========================
sudo apt update -y
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget curl

# =========================
# Cài Python 3.13
# =========================
cd /tmp
wget -q https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tgz
tar -xf Python-3.13.0.tgz
cd Python-3.13.0
./configure --enable-optimizations --prefix=/usr/local/python3.13
make -j$(nproc)
sudo make altinstall

# =========================
# pip + tomli cho Python 3.13
# =========================
/usr/local/python3.13/bin/python3.13 -m ensurepip --upgrade
/usr/local/python3.13/bin/python3.13 -m pip install --upgrade pip tomli

# =========================
# Chạy win.py bằng Python 3.13
# =========================
if [ -f "win.py" ]; then
    echo "▶ Running win.py using Python 3.13..."
    /usr/local/python3.13/bin/python3.13 win.py
else
    echo "❌ win.py not found"
fi
