#!/bin/bash

$username=

echo "ESP8266 Setup Environment Script!"

echo "Install Linux Debian depencies"
sudo apt-get install -y git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev python-serial libexpat1-dev

echo "Create /opt/Espressif dir"
#sudo rm -rf /opt/Espressif/
sudo mkdir -p /opt/Espressif

echo "Change /opt/Espressif/ owner to "$username
sudo chown $username /opt/Espressif/
