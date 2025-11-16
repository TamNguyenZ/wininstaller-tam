#!/bin/bash
set -e

echo "=== 🧹 Fix APT lỗi cnf-update-db ==="

# B1: Sửa quyền folder
sudo mkdir -p /var/lib/command-not-found
sudo chmod 755 /var/lib/command-not-found || true

# B2: Cài lại command-not-found
sudo apt --reinstall install -y command-not-found || true

# B3: Nếu script hỏng thì xóa nó
if [ -f /usr/lib/cnf-update-db ]; then
    sudo rm -f /usr/lib/cnf-update-db || true
fi

echo "=== ✅ APT đã fix xong ==="
sleep 1

echo "=== 🧰 Cài dependency build Python ==="

sudo apt update
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget

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

echo "=== 📥 Cài requests ==="
pip3.12 install requests

echo "=== 🎉 DONE! Python 3.12 + pip + requests đã cài thành công. ==="
python3.12 --version
pip3.12 --version
