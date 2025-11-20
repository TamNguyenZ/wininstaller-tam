#!/bin/bash
set -euo pipefail

# ==========================
# CHECK ROOT / FREEROOT
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
# CONFIG PYTHON 3.10
# ==========================
PYTHON_VER="3.10.13"
PYTHON_PREFIX="$HOME/python3.10"
VENV_DIR="$HOME/py310-env"

# ==========================
# INSTALL BUILD DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y \
build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
libxml2-dev libxslt1-dev libncursesw5-dev || true

# ==========================
# BUILD PYTHON 3.10
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.10" ]; then
    echo "🚀 Bắt đầu build Python 3.10 từ source..."
    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz" || true
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
    tar -xf "Python-$PYTHON_VER.tgz"
    cd "Python-$PYTHON_VER"
    ./configure --prefix="$PYTHON_PREFIX" --enable-optimizations --with-ensurepip=install --enable-shared
    make -j$(nproc)
    make install
    cd ..
    echo "✅ Build Python 3.10 xong!"
else
    echo "🔍 Python 3.10 đã tồn tại, bỏ qua build."
fi

# ==========================
# SET PATH + LD_LIBRARY_PATH
# ==========================
export PATH="$PYTHON_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Kiểm tra python3.10 ngay lập tức
"$PYTHON_PREFIX/bin/python3.10" --version || {
    echo "❌ Python 3.10 chưa chạy được! Kiểm tra LD_LIBRARY_PATH."
    exit 1
}

# ==========================
# CREATE VENV
# ==========================
rm -rf "$VENV_DIR" || true
"$PYTHON_PREFIX/bin/python3.10" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP + INSTALL FULL REQUESTS
# ==========================
pip install --upgrade pip setuptools wheel
pip install requests[security] urllib3[secure] certifi chardet idna charset_normalizer

# ==========================
# CHECK
# ==========================
echo "Python version:"
python --version
echo "Pip version:"
pip --version
echo "Installed requests version:"
python -c "import requests; print(requests.__version__)"

# ==========================
# RUN PY SCRIPT
# ==========================
if [ -f "runpy.sh" ]; then
    echo "▶️ Chạy runpy.sh với Python 3.10 + venv + requests full..."
    bash runpy.sh
else
    echo "❌ Không tìm thấy runpy.sh"
fi

echo "🎯 Hoàn tất!"
