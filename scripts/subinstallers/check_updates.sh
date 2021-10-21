#!/bin/bash

apt-get update

UPDATES=$(apt-get dist-upgrade -s --quiet=2 | grep -c ^Inst)

if [[ "$UPDATES" -ne "0" ]]; then
    echo "Please run updates and reboot before installing azureguard: sudo apt-get update && sudo apt-get -y dist-upgrade"
    exit 1;
fi
