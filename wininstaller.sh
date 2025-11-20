#!/bin/bash
set -euo pipefail

# ==========================
# CÀI DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y git build-essential libssl-dev zlib1g-dev \
libncurses5-dev libffi-dev libsqlite3-dev libreadline-dev \
libbz2-dev liblzma-dev tk-dev libgdbm-dev curl wget

# ==========================
# CÀI PYENV
# ==========================
curl https://pyenv.run | bash

# ==========================
# NẠP PYENV
# ==========================
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ==========================
# CÀI PYTHON 3.12.2
# ==========================
pyenv install -s 3.12.2
pyenv global 3.12.2

# ==========================
# KIỂM TRA
# ==========================
python --version
python -m pip install --upgrade pip
python -m pip install requests tomli tomli_w

# ==========================
# CHẠY FILE WIN.PY
# ==========================
if [ -f "win.py" ]; then
    python win.py
else
    echo "❌ Không tìm thấy win.py"
fi
