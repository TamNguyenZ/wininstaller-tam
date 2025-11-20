#!/bin/bash
set -euo pipefail

# ==========================
# CHECK ROOT / SUDO
# ==========================
if [ "$EUID" -eq 0 ]; then
    echo "OK: ✅ Đang chạy với quyền root"
else
    echo "⚠️ Không phải root → kiểm tra sudo..."
    if sudo -n true 2>/dev/null; then
        echo "OK: ✅ Có sudo không cần password (đủ quyền root)"
    else
        echo "❌ Không có root hoặc sudo → cài thủ công nếu cần"
    fi
fi

# ==========================
# VARIABLES
# ==========================
PYTHON_VER="3.10.13"
PYTHON_PREFIX="$HOME/python3.10"
VENV_DIR="$HOME/py310-env"
RUN_SCRIPT="runpy.sh"

# ==========================
# INSTALL DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y \
build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
libxml2-dev libxslt1-dev libncursesw5-dev || true

# ==========================
# BUILD PYTHON 3.10 FROM SOURCE
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.10" ]; then
    echo "🚀 Bắt đầu build Python 3.10 từ source..."
    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz" || true
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
    tar -xf "Python-$PYTHON_VER.tgz"
    cd "Python-$PYTHON_VER"
    ./configure --prefix="$PYTHON_PREFIX" \
                --enable-optimizations \
                --with-ensurepip=install \
                --enable-shared
    make -j$(nproc)
    make install
    cd ..
    echo "✅ Build Python 3.10 xong!"
else
    echo "🔍 Python 3.10 đã tồn tại, bỏ qua build."
fi

# ==========================
# SET ENVIRONMENT
# ==========================
export PATH="$PYTHON_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Kiểm tra Python
"$PYTHON_PREFIX/bin/python3.10" --version || { echo "❌ Python chưa chạy được!"; exit 1; }

# ==========================
# CREATE VIRTUALENV
# ==========================
rm -rf "$VENV_DIR" || true
"$PYTHON_PREFIX/bin/python3.10" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP + TOOLS
# ==========================
pip install --upgrade pip setuptools wheel tomli markdown packaging requests

# ==========================
# CHECK
# ==========================
echo "Python version:"
python --version
echo "Pip version:"
pip --version

# ==========================
# RUN runpy.sh
# ==========================
if [ -f "$RUN_SCRIPT" ]; then
    echo "▶️ Chạy $RUN_SCRIPT với Python 3.10 + venv..."
    bash "$RUN_SCRIPT"
else
    echo "❌ Không tìm thấy $RUN_SCRIPT trong folder hiện tại"
    exit 1
fi

echo "🎯 Hoàn tất! Python 3.10 + venv + runpy.sh đã chạy xong!"
