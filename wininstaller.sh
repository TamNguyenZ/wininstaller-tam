#!/bin/bash
set -euo pipefail

sudo apt update -y
sudo apt install -y git build-essential libssl-dev zlib1g-dev \
libncurses5-dev libffi-dev libsqlite3-dev libreadline-dev \
libbz2-dev liblzma-dev tk-dev libgdbm-dev curl

if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

pyenv install -s 3.13.0

PYTHON13_PATH="$(pyenv prefix 3.13.0)/bin/python3.13"
PYTHON13_VENV="$HOME/py313-env"
rm -rf "$PYTHON13_VENV"
$PYTHON13_PATH -m venv "$PYTHON13_VENV"

"$PYTHON13_VENV/bin/pip" install --upgrade pip setuptools wheel
"$PYTHON13_VENV/bin/pip" install tomli requests[security] urllib3 certifi idna charset_normalizer

if [ -f "win.py" ]; then
    echo "▶ Running win.py using Python 3.13 venv..."
    "$PYTHON13_VENV/bin/python" win.py
else
    echo "❌ win.py not found"
fi

