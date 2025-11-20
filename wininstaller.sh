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

echo "=== ✅ CHECK ROOT DONE ==="
sleep 1


# ==========================
# CONFIG PYTHON 3.12
# ==========================
PYTHON_VER="3.12.2"
PYTHON_PREFIX="$HOME/python312"
VENV_DIR="$HOME/py312-env"

echo "🚀 Setup Python $PYTHON_VER"

# ==========================
# INSTALL BUILD DEPENDENCIES
# ==========================
sudo apt update -y
sudo apt install -y \
build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
libxml2-dev libxslt1-dev libncursesw5-dev

# ==========================
# BUILD PYTHON 3.12
# ==========================
if [ ! -x "$PYTHON_PREFIX/bin/python3.12" ]; then
    echo "🔨 Building Python 3.12..."
    rm -rf "Python-$PYTHON_VER" "Python-$PYTHON_VER.tgz" || true
    wget "https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
    tar -xf "Python-$PYTHON_VER.tgz"
    cd "Python-$PYTHON_VER"

    ./configure \
        --prefix="$PYTHON_PREFIX" \
        --enable-optimizations \
        --with-ensurepip=install \
        --enable-shared

    make -j$(nproc)
    make install
    cd ..
else
    echo "✔ Python 3.12 đã tồn tại — skip build."
fi

# ==========================
# EXPORT PATH CHUẨN
# ==========================
export PATH="$PYTHON_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

"$PYTHON_PREFIX/bin/python3.12" --version

# ==========================
# CREATE VENV
# ==========================
rm -rf "$VENV_DIR" || true
"$PYTHON_PREFIX/bin/python3.12" -m venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

# ==========================
# INSTALL REQUESTS FULL
# ==========================
pip install --upgrade pip setuptools wheel
pip install "requests[security]" urllib3 certifi idna charset_normalizer

echo "📦 requests version:"
python3 - <<EOF
import requests
print("Requests:", requests.__version__)
EOF

# ==========================
# AUTO FIX RUNPY.SH
# ==========================
if [ -f "runpy.sh" ]; then
cat > runpy.sh <<EOF
#!/bin/bash
export PATH="$PYTHON_PREFIX/bin:\$PATH"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib:\$LD_LIBRARY_PATH"
source "$VENV_DIR/bin/activate"
python3.12 win.py
EOF
chmod +x runpy.sh
echo "⚡ Updated runpy.sh để luôn chạy Python 3.12."
fi

echo "🎯 DONE – Python 3.12 + venv + requests FULL READY!"
