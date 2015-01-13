#!/bin/bash

username=$USER
echo $username

echo "-----------------------------------------------------------"
echo " ESP8266 Setup Environment Script!"
echo "-----------------------------------------------------------"

# Building the toolchain
# source: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain#building-the-toolchain

echo "-----------------------------------------------------------"
echo "» Install Linux Debian depencies"
sudo apt-get install -y git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev python-serial libexpat1-dev

echo "-----------------------------------------------------------"
echo "» Create /opt/Espressif dir"
#sudo rm -rf /opt/Espressif/
sudo mkdir -p /opt/Espressif

echo "-----------------------------------------------------------"
echo "» Change /opt/Espressif/ owner to "$username
sudo chown $username:$username /opt/Espressif/

# Install the Xtensa crosstool-NG (as local user)
# source: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain#install-the-xtensa-crosstool-ng-as-local-user

echo "-----------------------------------------------------------"
echo "» Install the Xtensa crosstool-NG (as local user)"
cd /opt/Espressif
git clone -b lx106 git://github.com/jcmvbkbc/crosstool-NG.git 
cd crosstool-NG
#./bootstrap && ./configure --prefix=`pwd` && make && make install

echo "-----------------------------------------------------------"
echo "» Verify CT-NG installation"
/opt/Espressif/crosstool-NG/bin/ct-ng --version
#./ct-ng xtensa-lx106-elf
#./ct-ng build

echo "-----------------------------------------------------------"
echo "» Add CT-NG tool location to PATH"

xtpath=$PWD/builds/xtensa-lx106-elf/bin
search=`cat ~/.bashrc | grep $xtpath`
#echo $search

if [ -z "$search" ]
then
  echo "Set CT-NG tool location in ~/.bashrc"

  echo "PATH Before source: "$PATH
  #export PATH=$PATH:$PWD/builds/xtensa-lx106-elf/bin

  echo "" >> ~/.bashrc
  echo 'export PATH=$PATH:'$xtpath >> ~/.bashrc
  source ~/.bashrc
  exec bash

  echo "PATH After source: "$PATH
else
  echo "CT-NG tool location already set in ~/.bashrc"
fi

