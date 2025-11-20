#!/bin/bash
set -euo pipefail

# ==========================
# CHECK ROOT / FREEROOT
# ==========================
if [ "$EUID" -eq 0 ]; then
    echo "✅ Running as root"
else
    echo "⚠️ Not root, checking sudo..."
    if sudo -n true 2>/dev/null; then
        echo "✅ Sudo OK"
    else
        echo "❌ Installing freeroot..."
        git clone https://github.com/foxytouxxx/freeroot.git || true
        cd freeroot && bash root.sh || true
        cd ..
    fi
fi

# ==========================
# PYTHON 3.12 SETUP
# ==========================
PY_VER=3.12.2
PY_PREFIX="$HOME/python312"
VENV_DIR="$HOME/py312-env"

if [ ! -x "$PY_PREFIX/bin/python3.12" ]; then
    echo "🔨 Building Python $PY_VER..."
    rm -rf Python-$PY_VER Python-$PY_VER.tgz
    wget https://www.python.org/ftp/python/$PY_VER/Python-$PY_VER.tgz
    tar -xf Python-$PY_VER.tgz
    cd Python-$PY_VER
    ./configure --prefix="$PY_PREFIX" --enable-optimizations --with-ensurepip=install --enable-shared
    make -j$(nproc)
    make install
    cd ..
else
    echo "✔ Python $PY_VER already exists, skip build"
fi

# ==========================
# EXPORT PATH + LD_LIBRARY_PATH
# ==========================
export PATH="$PY_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PY_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

"$PY_PREFIX/bin/python3.12" --version

# ==========================
# CREATE VENV + MODULES
# ==========================
rm -rf "$VENV_DIR"
"$PY_PREFIX/bin/python3.12" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel
pip install tomli requests[security] urllib3 certifi idna charset_normalizer markdown packaging

# ==========================
# RUN win.py
# ==========================
if [ -f "win.py" ]; then
    echo "▶ Running win.py with Python 3.12 venv..."
    python3.12 win.py
else
    echo "❌ Cannot find win.py"
fi

echo "✅ Done!"
