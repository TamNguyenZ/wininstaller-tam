#!/bin/bash
set -euo pipefail

# ==========================
# CONFIG
# ==========================
PY_VER="3.13.1"
PREFIX="$HOME/python-$PY_VER"
VENV_DIR="$HOME/py313-env"

# ==========================
# FIND SCRIPT DIR
# ==========================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ==========================
# INSTALL BUILD DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    wget \
    libc6-dev \
    libexpat1-dev

# ==========================
# DETECT IF PYTHON 3.13 ALREADY BUILT
# ==========================
if [ -x "$PREFIX/bin/python3.13" ]; then
    echo "✔ Python 3.13.1 already exists at $PREFIX — skipping build"
else
    echo "▶ Python 3.13.1 not found — building..."

    # ==========================
    # DOWNLOAD SOURCE
    # ==========================
    cd /tmp
    wget "https://www.python.org/ftp/python/$PY_VER/Python-$PY_VER.tgz"
    tar -xf "Python-$PY_VER.tgz"
    cd "Python-$PY_VER"

    # ==========================
    # CONFIGURE + BUILD
    # ==========================
    ./configure \
      --prefix="$PREFIX" \
      --enable-optimizations \
      --with-lto \
      --enable-ipv6 \
      --enable-loadable-sqlite-extensions

    make -j"$(nproc)"
    make install
fi

# ==========================
# CREATE / RESET VENV
# ==========================
rm -rf "$VENV_DIR"
"$PREFIX/bin/python3.13" -m venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP + INSTALL LIBS
# ==========================
pip install --upgrade pip setuptools wheel

# FULL TOML SUPPORT: tomllib built-in Python 3.13
pip install tomli

pip install \
    requests \
    numpy \
    rich \
    pandas \
    pillow \
    psutil \
    py-cpuinfo \
    fastapi uvicorn \
    tqdm \
    colorama

echo "========================================="
echo "✔ DONE: Python 3.13 is ready!"
echo "✔ Prefix: $PREFIX"
echo "✔ Venv:   $VENV_DIR"
echo "========================================="

# ==========================
# RUN win.py
# ==========================
if [ -f "$SCRIPT_DIR/win.py" ]; then
    echo "▶ Running win.py..."
    python "$SCRIPT_DIR/win.py"
else
    echo "❌ win.py NOT found in: $SCRIPT_DIR"
    exit 1
fi
