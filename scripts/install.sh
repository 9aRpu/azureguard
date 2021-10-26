#!/usr/bin/env bash

set -e
# set -x
export DEBIAN_FRONTEND=noninteractive

# if [ "$EUID" -ne 0 ]
# then echo "Please run as root"
#     exit
# fi
AZGUARD_USER="azureguard"
if [ $(whoami) != "$AZGUARD_USER" ]; then
        echo "Creating user: $AZGUARD_USER"
        sudo useradd -s /bin/bash -d /home/$AZGUARD_USER -m -G sudo $AZGUARD_USER 2>/dev/null || true
        SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
        #echo "SCRIPTPATH: $SCRIPTPATH"
        FILENAME=$(basename -- "$0")
        #echo "FILENAME: $FILENAME"
        FULLPATH="$SCRIPTPATH/$FILENAME"
        #echo "FULLPATH: $FULLPATH"

        # SUDO
        case `sudo grep -e "^$AZGUARD_USER.*" /etc/sudoers >/dev/null; echo $?` in
        0)
            echo "$AZGUARD_USER already in sudoers"
            ;;
        1)
            echo "Adding $AZGUARD_USER to sudoers"
            sudo bash -c "echo '$AZGUARD_USER  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
            ;;
        *)
            echo "There was a problem checking sudoers"
            ;;
        esac
       
        # get git branch if one exists (default to master)
        pushd .
        cd "$SCRIPTPATH"
        GIT_BRANCH=$(git symbolic-ref --short HEAD || echo "main")
        popd

        sudo cp "$FULLPATH" /home/$AZGUARD_USER
        sudo chown $AZGUARD_USER:$AZGUARD_USER "/home/$AZGUARD_USER/$FILENAME"
        sudo SSH_CLIENT="$SSH_CLIENT" GIT_BRANCH="$GIT_BRANCH" -i -u $AZGUARD_USER bash -c "/home/$AZGUARD_USER/$FILENAME" # self-referential call
        exit 0
fi

echo "Running as $USER"

echo -e "    ___                        ______                     __"
echo -e "   /   |____  __  __________  / ____/_  ______ __________/ /"
echo -e "  / /| /_  / / / / / ___/ _ \/ / __/ / / / __  / ___/ __  / "
echo -e " / ___ |/ /_/ /_/ / /  /  __/ /_/ / /_/ / /_/ / /  / /_/ /  "
echo -e "/_/  |_/___/\__,_/_/   \___/\____/\__,_/\__,_/_/   \__,_/   "
echo -e "                                                            "

sudo rm -rf /opt/azureguard 2>/dev/null || true

sudo apt-get install -yq git

# Clone to /opt
echo "Cloning $GIT_BRANCH branch from azureguard repo"
sudo git clone https://github.com/9aRpu/azureguard -b $GIT_BRANCH /opt/azureguard
sudo chown -R "$USER":"$USER" /opt/azureguard
cd /opt/azureguard

# Check updates
echo "Checking updates"
source ./scripts/subinstallers/check_updates.sh

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
source ./scripts/subinstallers/platform.sh

# Install kernel headers
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
    sudo apt-get install -yq linux-headers-"$(uname -r)"
else
    echo "Unsupported OS: $DISTRO"
    exit 1
fi

# Wireugard
source ./scripts/subinstallers/wireguard.sh

# Blobfuse
source ./scripts/subinstallers/blobfuse.sh

# Mount service for blobfuse
sudo mkdir -p /mnt/blobfusetmp/wireguard
sudo cp ./services/mount_wg.service /etc/systemd/system/
# TODO: connection config


# Azure CLI
source ./scripts/subinstallers/azcli.sh

# unattended upgrades
sudo cp ./conf/20auto-upgrades /etc/apt/apt.conf.d/
sudo cp ./conf/50unattended-upgrades /etc/apt/apt.conf.d/

sudo systemctl stop unattended-upgrades
sudo systemctl daemon-reload
sudo systemctl restart unattended-upgrades

[[ ! -f /usr/local/bin/azg ]] && sudo ln -s /opt/azureguard/cli/azg /usr/local/bin/azg