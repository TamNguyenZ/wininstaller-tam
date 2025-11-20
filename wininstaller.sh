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
# PYTHON VERSIONS
# ==========================
PY310_VER="3.10.13"
PY312_VER="3.12.2"

PY310_PREFIX="$HOME/python310"
PY312_PREFIX="$HOME/python312"

VENV310="$HOME/py310-env"
VENV312="$HOME/py312-env"

echo "🚀 Setup Python 3.10 + Python 3.12"

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
# FUNCTION: BUILD PYTHON
# ==========================
build_python () {
    local VER=$1
    local PREFIX=$2

    if [ ! -x "$PREFIX/bin/python${VER%.*}" ]; then
        echo "🔨 Building Python $VER..."
        rm -rf "Python-$VER" "Python-$VER.tgz" || true

        wget "https://www.python.org/ftp/python/$VER/Python-$VER.tgz"
        tar -xf "Python-$VER.tgz"
        cd "Python-$VER"

        ./configure \
            --prefix="$PREFIX" \
            --enable-optimizations \
            --with-ensurepip=install \
            --enable-shared

        make -j$(nproc)
        make install
        cd ..
    else
        echo "✔ Python $VER đã tồn tại — skip build."
    fi
}

# ==========================
# BUILD BOTH PYTHONS
# ==========================
build_python "$PY310_VER" "$PY310_PREFIX"
build_python "$PY312_VER" "$PY312_PREFIX"

# ==========================
# FUNCTION: CREATE VENV + INSTALL MODULES
# ==========================
setup_env () {
    local PREFIX=$1
    local VENV=$2
    local BINPY="$PREFIX/bin/python${PREFIX##*python}${BINPY}"

    rm -rf "$VENV" || true
    "$PREFIX/bin/python${PREFIX##*python}" -m venv "$VENV"

    source "$VENV/bin/activate"

    pip install --upgrade pip setuptools wheel
    pip install "requests[security]" urllib3 certifi idna charset_normalizer
    pip install tomli tomli_w

    deactivate
}

# ==========================
# SETUP ENV FOR BOTH
# ==========================
setup_env "$PY310_PREFIX" "$VENV310"
setup_env "$PY312_PREFIX" "$VENV312"

# ==========================
# MAKE runpy310.sh
# ==========================
cat > runpy310.sh <<EOF
#!/bin/bash
export PATH="$PY310_PREFIX/bin:\$PATH"
export LD_LIBRARY_PATH="$PY310_PREFIX/lib:\$LD_LIBRARY_PATH"
source "$VENV310/bin/activate"
python3.10 win.py
EOF
chmod +x runpy310.sh
echo "⚡ Created runpy310.sh"

# ==========================
# MAKE runpy312.sh
# ==========================
cat > runpy312.sh <<EOF
#!/bin/bash
export PATH="$PY312_PREFIX/bin:\$PATH"
export LD_LIBRARY_PATH="$PY312_PREFIX/lib:\$LD_LIBRARY_PATH"
source "$VENV312/bin/activate"
python3.12 win.py
EOF
chmod +x runpy312.sh
echo "⚡ Created runpy312.sh"

echo "🎯 DONE – Python 3.10 + 3.12 + 2 venv + requests + tomli fully installed!"
