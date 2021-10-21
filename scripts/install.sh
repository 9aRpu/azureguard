#!/bin/bash

set -e
# set -x
export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

echo -e "    ___                        ______                     __"
echo -e "   /   |____  __  __________  / ____/_  ______ __________/ /"
echo -e "  / /| /_  / / / / / ___/ _ \/ / __/ / / / __  / ___/ __  / "
echo -e " / ___ |/ /_/ /_/ / /  /  __/ /_/ / /_/ / /_/ / /  / /_/ /  "
echo -e "/_/  |_/___/\__,_/_/   \___/\____/\__,_/\__,_/_/   \__,_/   "
echo -e "                                                            "

rm -rf /opt/azureguard 2>/dev/null || true

apt-get install -yq git

GIT_BRANCH=main

# Clone to /opt
echo "Cloning $GIT_BRANCH branch from azureguard repo"
git clone https://github.com/9aRpu/azureguard -b $GIT_BRANCH /opt/azureguard

# Check updates
echo "Checking updates"
source /opt/azureguard/scripts/subinstallers/check_updates.sh

# SSH keys
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH keypair for $USER"
    ssh-keygen -t rsa -b 4096 -N "" -m pem -f ~/.ssh/id_rsa -q
    
    # Authorized keys
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
else
    echo "SSH key exists for $USER"
fi

# Get OS and distro
source /opt/azureguard/scripts/subinstallers/platform.sh

# Install kernel headers
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    apt-get install -yq linux-headers-"$(uname -r)"
else
    echo "Unsupported OS: $DISTRO"
    exit 1
fi

# Wireugard
source /opt/azureguard/scripts/subinstallers/wireguard.sh

# Blobfuse
source /opt/azureguard/scripts/subinstallers/blobfuse.sh

# unattended upgrades
cp ./conf/20auto-upgrades /etc/apt/apt.conf.d/
cp ./conf/50unattended-upgrades /etc/apt/apt.conf.d/

systemctl stop unattended-upgrades
systemctl daemon-reload
systemctl restart unattended-upgrades