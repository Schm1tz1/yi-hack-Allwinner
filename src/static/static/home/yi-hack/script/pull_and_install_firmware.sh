#!/bin/sh

YI_HACK_PREFIX="/home/yi-hack"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:$YI_HACK_PREFIX/lib:/tmp/sd/yi-hack/lib
export PATH=$PATH:/home/base/tools:$YI_HACK_PREFIX/bin:$YI_HACK_PREFIX/sbin:/tmp/sd/yi-hack/bin:/tmp/sd/yi-hack/sbin

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <URL of firmware to download and install>"
  exit
fi

FIRMWARE_URL="$1"
FIRMWARE_FILENAME=$(echo "${FIRMWARE_URL}" | grep -o '[^/]*$') # extracts last part of URL as filename

FREE_SD_KiB=$(df /tmp/sd/ | grep mmc | awk '{print $4}')
if [ -z "$FREE_SD_KiB" ]; then
  printf "Content-type: text/html\r\n\r\n"
  printf "No SD detected."
  exit
fi

if [ "$FREE_SD_KiB" -lt 100000 ]; then
  printf "Content-type: text/html\r\n\r\n"
  printf "Not enough space left on SD (100MB)."
  exit
fi

# Clean old upgrades
rm -rf /tmp/sd/fw_upgrade
rm -rf /tmp/sd/Factory
rm -rf /tmp/sd/newhome

mkdir -p /tmp/sd/fw_upgrade
cd /tmp/sd/fw_upgrade || exit

$YI_HACK_PREFIX/usr/bin/wget "$FIRMWARE_URL"
if [ ! -f "$FIRMWARE_FILENAME" ]; then
  printf "Content-type: text/html\r\n\r\n"
  printf "Unable to download firmware file."
  exit
fi

tar zxvf "$FIRMWARE_FILENAME"
rm "$FIRMWARE_FILENAME"
cp -rf ./* ..
rm -rf /tmp/sd/fw_upgrade/*

cp -f $YI_HACK_PREFIX/etc/*.conf .
if [ -f $YI_HACK_PREFIX/etc/hostname ]; then
  cp -f $YI_HACK_PREFIX/etc/hostname .
fi

# Report the status to the caller
printf "Content-type: text/html\r\n\r\n"
printf "Download completed, rebooting and upgrading."

sync
sync
sync
sleep 1
reboot
