#!/bin/bash

# Install blobfuse
sudo wget -O /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/$DISTRO/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
sudo apt-get update 
sudo apt-get install -yq blobfuse

sudo rm /tmp/packages-microsoft-prod.deb