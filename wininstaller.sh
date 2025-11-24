#!/bin/bash
set -euo pipefail

# ==========================
# CONFIG
# ==========================
PY313="3.13.1"
PREFIX313="$HOME/python-$PY313"
VENV313="$HOME/py313-env"

PY312="3.12.2"
VENV312="$HOME/py312-env"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ==========================
# INSTALL DEPENDENCIES (BUILD 3.13)
# ==========================
sudo apt update -y
sudo apt install -y \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
    libnss3-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev libbz2-dev liblzma-dev tk-dev uuid-dev \
    wget libc6-dev libexpat1-dev curl git

# ==========================
# BUILD PYTHON 3.13 (FULL)
# ==========================
build_py313() {
    echo "▶ Building Python $PY313 ..."

    cd /tmp
    wget "https://www.python.org/ftp/python/$PY313/Python-$PY313.tgz"
    tar -xf "Python-$PY313.tgz"
    cd "Python-$PY313"

    ./configure \
        --prefix="$PREFIX313" \
        --enable-optimizations \
        --with-lto \
        --enable-ipv6 \
        --enable-loadable-sqlite-extensions

    make -j"$(nproc)"
    make install
}

# ---- Check + Build
if [ ! -x "$PREFIX313/bin/python3.13" ]; then
    build_py313
else
    echo "✔ Python $PY313 đã build → skip"
fi

# ==========================
# CREATE VENV 3.13
# ==========================
rm -rf "$VENV313"
"$PREFIX313/bin/python3.13" -m venv "$VENV313"

source "$VENV313/bin/activate"
pip install --upgrade pip setuptools wheel tomli
pip install requests numpy rich pandas pillow psutil py-cpuinfo fastapi uvicorn tqdm colorama
deactivate

echo "=========================================="
echo "✔ Python 3.13 build full OK"
echo "✔ Venv: $VENV313"
echo "=========================================="

# ==========================
# PYENV INSTALL PYTHON 3.12
# ==========================
if [ ! -d "$HOME/.pyenv" ]; then
    echo "▶ Installing pyenv..."
    curl https://pyenv.run | bash
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

pyenv install -s "$PY312"

PY312_PATH="$(pyenv prefix $PY312)/bin/python3.12"

# ==========================
# CREATE VENV 3.12 (FOR win.py)
# ==========================
rm -rf "$VENV312"
"$PY312_PATH" -m venv "$VENV312"

source "$VENV312/bin/activate"
pip install --upgrade pip setuptools wheel
pip install requests tomli
deactivate

echo "=========================================="
echo "✔ Python 3.12 (pyenv) ready"
echo "✔ Venv: $VENV312"
echo "=========================================="

# ==========================
# RUN win.py USING PYTHON 3.12
# ==========================
if [ -f "$SCRIPT_DIR/win.py" ]; then
    echo "▶ Running win.py with Python 3.12..."
    "$VENV312/bin/python" "$SCRIPT_DIR/win.py"
else
    echo "❌ win.py not found in $SCRIPT_DIR"
    exit 1
fi
