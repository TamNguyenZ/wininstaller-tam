#!/bin/bash
set -euo pipefail

# ==========================
# CONFIG
# ==========================
PY_VER="3.13.1"
PREFIX="$HOME/python-$PY_VER"
VENV_DIR="$HOME/py313-env"

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

# ==========================
# CREATE VENV PY313
# ==========================
$PREFIX/bin/python3.13 -m venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP + INSTALL LIBS
# ==========================
pip install --upgrade pip setuptools wheel

# FULL TOML SUPPORT: tomllib đã built-in Python 3.13
pip install tomli

# Mấy libs phổ biến
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
echo "✔ DONE: Python 3.13 installed!"
echo "✔ Prefix: $PREFIX"
echo "✔ Venv:   $VENV_DIR"
echo "✔ tomllib built-in + tomli installed"
echo "========================================="

# ==========================
# RUN win.py
# ==========================
echo "▶ Running win.py..."
python "$(dirname "$0")/win.py"
