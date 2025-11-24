# ==========================
# RUN win.py
# ==========================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "$SCRIPT_DIR/win.py" ]; then
    echo "▶ Running win.py..."
    python "$SCRIPT_DIR/win.py"
else
    echo "❌ win.py not found in: $SCRIPT_DIR"
    exit 1
fi
