#!/bin/bash
set -e -u -o errexit

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
sudo apt install -y \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
    xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
    libxml2-dev libxslt1-dev libncursesw5-dev libffi-dev liblzma-dev || true

# ==========================
# BUILD PYTHON 3.12
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.12" ]; then
    echo "🚀 Bắt đầu build Python 3.12 từ source..."
    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz" || true
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
    tar -xf "Python-$PYTHON_VER.tgz"
    cd "Python-$PYTHON_VER"

    ./configure --prefix="$PYTHON_PREFIX" --enable-optimizations --with-ensurepip=install --enable-shared
    make -j$(nproc)
    make install
    cd ..
    echo "✅ Build Python 3.12 xong!"
else
    echo "🔍 Python 3.12 đã tồn tại, bỏ qua build."
fi

# ==========================
# UPDATE PATH & LD_LIBRARY_PATH
# ==========================
export PATH="$PYTHON_PREFIX/bin:$PATH"
: "${LD_LIBRARY_PATH:=}"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib:$LD_LIBRARY_PATH"

if ! command -v python3.12 &>/dev/null; then
    echo "❌ Python 3.12 vẫn chưa có trong PATH, kiểm tra lại!"
    exit 1
fi

# ==========================
# CREATE VENV
# ==========================
rm -rf "$VENV_DIR" || true
"$PYTHON_PREFIX/bin/python3.12" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ==========================
# UPGRADE PIP
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
# RUN PY SCRIPT
# ==========================
echo "▶️ Chạy runpy.sh..."
bash runpy.sh || true

echo "🎯 Hoàn tất!" thấy runpy.sh, bỏ qua bước này."
fi

echo "🎯 Hoàn tất toàn bộ!"ng — không quan trọng Python có lỗi hay không."

# ==========================
# LUÔN LUÔN CHẠY RUNPY.SH
# ==========================
echo "▶️ Đang chạy runpy.sh..."
bash runpy.sh || true

echo "🎯 Hoàn tất toàn bộ!"