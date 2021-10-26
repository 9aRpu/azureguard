#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -yq git

git clone https://github.com/9aRpu/azureguard
bash ./azureguard/scripts/install.sh