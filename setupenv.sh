#!/bin/bash

username=$USER
echo $username

trap "exit" SIGHUP SIGINT SIGTERM

echo "-----------------------------------------------------------"
echo " ESP8266 Setup Environment Script!"

#if [ -f "dummy.txt" ]; then

# ****************************************************************
# Building the toolchain
# source: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain#building-the-toolchain
# ****************************************************************

echo "-----------------------------------------------------------"
echo "» Install Linux Debian depencies"
# Debian
sudo apt-get install -y git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev python-serial libexpat1-dev
# Ubuntu
#sudo apt-get install -y git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev-amd64 python-serial libexpat-dev

echo "-----------------------------------------------------------"
echo "» Create /opt/Espressif dir"
##sudo rm -rf /opt/Espressif/
sudo mkdir -p /opt/Espressif

echo "-----------------------------------------------------------"
echo "» Change /opt/Espressif/ owner to "$username
sudo chown $username:$username /opt/Espressif/

# ****************************************************************
# Install the Xtensa crosstool-NG (as local user)
# source: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain#install-the-xtensa-crosstool-ng-as-local-user
# ****************************************************************

echo "-----------------------------------------------------------"
echo "» Install the Xtensa crosstool-NG (as local user)"
cd /opt/Espressif
git clone -b lx106 git://github.com/jcmvbkbc/crosstool-NG.git
cd crosstool-NG
./bootstrap && ./configure --prefix=`pwd` && make && make install

echo "-----------------------------------------------------------"
echo "» Verify CT-NG installation"
/opt/Espressif/crosstool-NG/bin/ct-ng --version
./ct-ng xtensa-lx106-elf
./ct-ng build

echo "-----------------------------------------------------------"
echo "» Add CT-NG tool location to PATH"

xtpath=$PWD/builds/xtensa-lx106-elf/bin
search=`cat ~/.bashrc | grep $xtpath`
#echo $search

if [ -z "$search" ]
then
  echo "Set CT-NG tool location in ~/.bashrc"

  #echo "PATH Before source: "$PATH
  #export PATH=$PATH:$PWD/builds/xtensa-lx106-elf/bin

  echo "" >> ~/.bashrc
  echo 'export PATH=$PATH:'$xtpath >> ~/.bashrc
  source ~/.bashrc
  exec bash

  #echo "PATH After source: "$PATH
else
  echo "CT-NG tool location already set in ~/.bashrc"
fi

#fi
# ****************************************************************
# Setting up the Espressif SDK
# source: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain#setting-up-the-espressif-sdk
# ****************************************************************

echo "-----------------------------------------------------------"
echo "» Setting up the Espressif SDK"

cd /opt/Espressif
rm -rf ESP8266_SDK
rm -rf esp_iot_sdk_v0.9.3
mkdir -p ESP8266_SDK
wget -O esp_iot_sdk_v0.9.3_14_11_21.zip https://github.com/esp8266/esp8266-wiki/raw/master/sdk/esp_iot_sdk_v0.9.3_14_11_21.zip
wget -O esp_iot_sdk_v0.9.3_14_11_21_patch1.zip https://github.com/esp8266/esp8266-wiki/raw/master/sdk/esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
unzip -o esp_iot_sdk_v0.9.3_14_11_21.zip
unzip -o esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
mv esp_iot_sdk_v0.9.3 ESP8266_SDK
mv License ESP8266_SDK/esp_iot_sdk_v0.9.3
rm esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
rm esp_iot_sdk_v0.9.3_14_11_21.zip

echo "-----------------------------------------------------------"
echo "» Patching the Espressif SDK"

cd /opt/Espressif/ESP8266_SDK/esp_iot_sdk_v0.9.3/
sed -i -e 's/xt-ar/xtensa-lx106-elf-ar/' -e 's/xt-xcc/xtensa-lx106-elf-gcc/' -e 's/xt-objcopy/xtensa-lx106-elf-objcopy/' Makefile
mv examples/IoT_Demo .


echo "-----------------------------------------------------------"
echo "» Installing Xtensa libraries and headers"

cd /opt/Espressif/ESP8266_SDK/esp_iot_sdk_v0.9.3/
wget -O lib/libc.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libc.a
wget -O lib/libhal.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libhal.a
wget -O include.tgz https://github.com/esp8266/esp8266-wiki/raw/master/include.tgz
tar -xvzf include.tgz

echo "-----------------------------------------------------------"
echo "» Installing the ESP image tool"

cd /opt/Espressif
wget -O esptool_0.0.2-1_i386.deb https://github.com/esp8266/esp8266-wiki/raw/master/deb/esptool_0.0.2-1_i386.deb
sudo dpkg -i esptool_0.0.2-1_i386.deb

echo "-----------------------------------------------------------"
echo "» Installing the ESP upload tool"

cd /opt/Espressif
git clone https://github.com/themadinventor/esptool esptool-py
sudo ln -s $PWD/esptool-py/esptool.py crosstool-NG/builds/xtensa-lx106-elf/bin/


# ****************************************************************
# Cross-Compile OLIMEX demo code
# source: https://olimex.wordpress.com/2015/01/29/esp8266-building-hello-world-blink-led-and-simple-web-server-to-drive-the-relay-and-check-button-status/
# ****************************************************************

echo "-----------------------------------------------------------"
echo "» Cross-Compile Olimex Blink Led demo"

echo "-> ESP Blink Led"
cd /opt/Espressif
git clone https://github.com/OLIMEX/ESP8266.git
cd ESP8266-EVB-blinkLED
make

echo "-> ESP HTTPD"
cd /opt/Espressif
cd ESP8266/esphttpd
make