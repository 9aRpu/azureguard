#!/bin/bash

# Install blobfuse
wget -O /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/$DISTRO/$VERSION_ID/packages-microsoft-prod.deb
dpkg -i /tmp/packages-microsoft-prod.deb
apt-get update 
apt-get install -yq blobfuse

rm /tmp/packages-microsoft-prod.deb