#!/bin/bash
set -euo pipefail

# ==========================
# PATH + LD_LIBRARY_PATH cho Python 3.10 build từ source
# ==========================
PYTHON_PREFIX="$HOME/python3.10"
VENV_DIR="$HOME/py310-env"

export PATH="$PYTHON_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PYTHON_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# ==========================
# Kích hoạt venv
# ==========================
if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "❌ Venv chưa tồn tại ở $VENV_DIR"
    exit 1
fi

# ==========================
# Chạy win.py
# ==========================
if [ -f "win.py" ]; then
    python win.py
else
    echo "❌ Không tìm thấy file win.py trong folder hiện tại"
    exit 1
fi
