#!/bin/bash
set -e

#!/bin/bash

# Kiểm tra có đang là root thật không
if [ "$EUID" -eq 0 ]; then
    echo "OK: ✅ Đang chạy với quyền root"
else
    echo "⚠️ Không phải root → kiểm tra sudo..."

    # Kiểm tra sudo không cần password
    if sudo -n true 2>/dev/null; then
        echo "OK: ✅ Có sudo không cần password (đủ quyền root)"
    else
        echo "❌ Không có root hoặc sudo → tiến hành cài freeroot"

        git clone https://github.com/foxytouxxx/freeroot.git
        cd freeroot && bash root.sh
    fi
fi

# Chỗ này không có exit → script sẽ tiếp tục chạy các lệnh bên dưới
echo "=== Script vẫn tiếp tục chạy bình thường ==="

echo "=== ✅ APT đã fix xong ==="
sleep 1


# ==========================
#   CHECK PYTHON 3.12
# ==========================

if command -v python3.12 &>/dev/null; then
    echo "=== 🔍 Python 3.12 đã tồn tại, bỏ qua bước build ==="
    python3.12 --version

    # nếu pip thiếu thì cài lại ensurepip
    if ! command -v pip3.12 &>/dev/null; then
        echo "=== ⚠️ Thiếu pip3.12 → cài ensurepip ==="
        python3.12 -m ensurepip --upgrade
    fi

else
    echo "=== ❌ Chưa có Python 3.12 → tiến hành build từ source ==="

    echo "=== 🧰 Cài dependency build Python ==="
    sudo apt update
    sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget \
    xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev \
    libxml2-dev libxslt1-dev

    echo "=== 📦 Tải và giải nén Python 3.12.0 ==="
    rm -rf Python-3.12.0 Python-3.12.0.tgz
    wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
    tar -xvf Python-3.12.0.tgz
    cd Python-3.12.0

    echo "=== ⚙️ Build Python 3.12.0 ==="
    ./configure --enable-optimizations --with-ensurepip=install
    make -j$(nproc)
    sudo make altinstall

    echo "=== 🔗 update-alternatives ==="
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.12 1
    sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.12 1
    sudo update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3.12 1

fi


echo "=== 📥 Đảm bảo requests đã được cài ==="
pip3.12 install -U pip setuptools wheel
pip3.12 install requests

echo "=== 🎉 DONE! Python 3.12 + pip + requests đã sẵn sàng ==="
python3.12 --version
pip3.12 --version

echo "=== ➕ Cài thêm thư viện hệ thống (xz, lzma, v.v.) ==="
sudo apt update
sudo apt install -y xz-utils liblzma-dev libbz2-dev uuid-dev tk-dev libxml2-dev libxslt1-dev
