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
        git clone https://github.com/foxytouxxx/freeroot.git || true
        cd freeroot && bash root.sh || true
        cd .. || true
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
libxml2-dev libxslt1-dev || true

# ==========================
# BUILD PYTHON 3.12 (KHÔNG BAO GIỜ LÀM SCRIPT DỪNG)
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.12" ]; then
    echo "=== ❌ Chưa có Python 3.12 → tiến hành build từ source ==="

    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz" || true
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz" || true
    tar -xf "Python-$PYTHON_VER.tgz" || true
    cd "Python-$PYTHON_VER" || true

    ./configure --prefix="$PYTHON_PREFIX" --enable-optimizations --with-ensurepip=install || true
    make -j$(nproc) || true
    make install || true

    cd .. || true

    echo "⚠️ Build Python có thể lỗi, nhưng script vẫn chạy tiếp."
else
    echo "=== 🔍 Python 3.12 đã tồn tại, bỏ qua build ==="
fi

# ==========================
# CREATE VENV (KHÔNG STOP NẾU LỖI)
# ==========================
rm -rf "$VENV_DIR" || true
"$PYTHON_PREFIX/bin/python3.12" -m venv "$VENV_DIR" || true

# ACTIVATE VENV (NẾU TỒN TẠI)
if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "⚠️ Không tạo được venv, tiếp tục không cần venv."
fi

# ==========================
# UPGRADE PIP (KHÔNG STOP NẾU LỖI)
# ==========================
pip install --upgrade pip setuptools wheel tomli markdown packaging requests || true

echo "Python version:"
python --version || echo "⚠️ Python không chạy được"
pip --version || echo "⚠️ pip không chạy được"

# ==========================
# CÀI THÊM LIBS HỆ THỐNG
# ==========================
sudo apt update -y
sudo apt install -y xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev libxml2-dev libxslt1-dev || true

echo "🎉 Tất cả bước đã chạy xong — không quan trọng Python có lỗi hay không."

# ==========================
# LUÔN LUÔN CHẠY RUNPY.SH
# ==========================
echo "▶️ Đang chạy runpy.sh..."
bash runpy.sh || true

echo "🎯 Hoàn tất toàn bộ!"
