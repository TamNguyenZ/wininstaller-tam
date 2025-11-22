#!/bin/bash
set -euo pipefail

# ==========================
# INSTALL DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y git build-essential libssl-dev zlib1g-dev \
libncurses5-dev libffi-dev libsqlite3-dev libreadline-dev \
libbz2-dev liblzma-dev tk-dev libgdbm-dev curl

# ==========================
# INSTALL PYENV
# ==========================
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ==========================
# INSTALL PYTHON 3.13 + 3.12
# ==========================
pyenv install -s 3.13.0
pyenv install -s 3.12.2

# ==========================
# CREATE VENV FOR BOTH
# ==========================
PYTHON13_PATH="$(pyenv prefix 3.13.0)/bin/python3.13"
PYTHON12_PATH="$(pyenv prefix 3.12.2)/bin/python3.12"

PYTHON13_VENV="$HOME/py313-env"
PYTHON12_VENV="$HOME/py312-env"

rm -rf "$PYTHON13_VENV" "$PYTHON12_VENV"

$PYTHON13_PATH -m venv "$PYTHON13_VENV"
$PYTHON12_PATH -m venv "$PYTHON12_VENV"

# ==========================
# INSTALL REQUESTS FULL
# ==========================
source "$PYTHON13_VENV/bin/activate"
pip install --upgrade pip setuptools wheel
pip install "requests[security]" urllib3 certifi idna charset_normalizer tomli
deactivate

source "$PYTHON12_VENV/bin/activate"
pip install --upgrade pip setuptools wheel
pip install "requests[security]" urllib3 certifi idna charset_normalizer tomli
deactivate

# ==========================
# RUN WIN.PY USING PYTHON 3.12
# ==========================
if [ -f "win.py" ]; then
    echo "▶ Running win.py using Python 3.12 venv..."
    source "$PYTHON12_VENV/bin/activate"
    python win.py
else
    echo "❌ win.py not found"
fi
