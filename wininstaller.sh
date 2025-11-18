#!/bin/bash
set -euo pipefail

# ==========================
#  CHECK ROOT / FREEROOT
# ==========================
if [ "$EUID" -eq 0 ]; then
    echo "OK: ✅ Đang chạy với quyền root"
else
    echo "⚠️ Không phải root → kiểm tra sudo..."
    if sudo -n true 2>/dev/null; then
        echo "OK: ✅ Có sudo không cần password (đủ quyền root)"
    else
        echo "❌ Không có root hoặc sudo → tiến hành cài freeroot"
        git clone https://github.com/foxytouxxx/freeroot.git
        cd freeroot && bash root.sh
        cd ..
    fi
fi

echo "=== ✅ APT đã fix xong ==="
sleep 1

# ==========================
# CONFIG PYTHON 3.12
# ==========================
PYTHON_VER="3.12.0"
PYTHON_PREFIX="$HOME/python3.12"
VENV_DIR="$HOME/py312-env"

# ==========================
# INSTALL BUILD DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
libxml2-dev libxslt1-dev

# ==========================
# BUILD PYTHON 3.12 IF NEEDED
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.12" ]; then
    echo "=== ❌ Chưa có Python 3.12 → tiến hành build từ source ==="

    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz"
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
    tar -xf "Python-$PYTHON_VER.tgz"
    cd "Python-$PYTHON_VER"

    ./configure --prefix="$PYTHON_PREFIX" --enable-optimizations --with-ensurepip=install
    make -j$(nproc)
    make install

    cd ..
else
    echo "=== 🔍 Python 3.12 đã tồn tại, bỏ qua build ==="
fi

# ==========================
# CREATE VENV
# ==========================
rm -rf "$VENV_DIR"
"$PYTHON_PREFIX/bin/python3.12" -m venv "$VENV_DIR"

# ACTIVATE VENV
source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP + INSTALL REQUESTS
# ==========================
pip install --upgrade pip setuptools wheel tomli markdown packaging requests

echo "✅ Python 3.12 + pip + requests sẵn sàng trong venv: $VENV_DIR"
python --version
pip --version

# ==========================
# CÀI THÊM HỆ THỐNG LIBS (LẦN CUỐI)
# ==========================
sudo apt update -y
sudo apt install -y xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev libxml2-dev libxslt1-dev

echo "🎉 Tất cả đã build xong hoàn chỉnh!"

# ==========================
# CHẠY SCRIPT runpy.sh BÊN TRONG VENV
# ==========================
echo "▶️ Đang chạy runpy.sh..."
bash runpy.sh

echo "🎯 Hoàn tất!"
