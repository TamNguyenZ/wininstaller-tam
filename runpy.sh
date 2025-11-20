#!/bin/bash
set -euo pipefail

# Kích hoạt venv Python 3.12
source "$HOME/py312-env/bin/activate"

# Chạy script win.py
python "$HOME/win.py"
