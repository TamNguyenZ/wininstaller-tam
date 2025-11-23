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
pyenv install -s 3.12.2

PYTHON13_PATH="$(pyenv prefix 3.13.0)/bin/python3.13"
PYTHON12_PATH="$(pyenv prefix 3.12.2)/bin/python3.12"

PYTHON13_VENV="$HOME/py313-env"
PYTHON12_VENV="$HOME/py312-env"

rm -rf "$PYTHON13_VENV" "$PYTHON12_VENV"

$PYTHON13_PATH -m venv "$PYTHON13_VENV"
$PYTHON12_PATH -m venv "$PYTHON12_VENV"

for VENV in "$PYTHON13_VENV" "$PYTHON12_VENV"; do
    source "$VENV/bin/activate"
    pip install --upgrade pip setuptools wheel
    pip install "requests[security]" urllib3 certifi idna charset_normalizer tomli
    deactivate
done

if [ -f "win.py" ]; then
    "$PYTHON12_VENV/bin/python" win.py
else
    echo "❌ win.py not found"
fi