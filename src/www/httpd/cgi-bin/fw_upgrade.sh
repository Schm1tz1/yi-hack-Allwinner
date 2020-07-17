#!/bin/sh

YI_HACK_PREFIX="/home/yi-hack"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:$YI_HACK_PREFIX/lib:/tmp/sd/yi-hack/lib
export PATH=$PATH:/home/base/tools:$YI_HACK_PREFIX/bin:$YI_HACK_PREFIX/sbin:/tmp/sd/yi-hack/bin:/tmp/sd/yi-hack/sbin

NAME="$(echo $QUERY_STRING | cut -d'=' -f1)"
VAL="$(echo $QUERY_STRING | cut -d'=' -f2)"

if [ "$NAME" != "get" ]; then
  exit
fi

if [ "$VAL" == "info" ]; then
  printf "Content-type: application/json\r\n\r\n"

  FW_VERSION=$(cat $YI_HACK_PREFIX/version)
  LATEST_FW=$($YI_HACK_PREFIX/usr/bin/wget -O - https://api.github.com/repos/roleoroleo/yi-hack-Allwinner/releases/latest 2>&1 | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  printf "{\n"
  printf "\"%s\":\"%s\",\n" "fw_version" "$FW_VERSION"
  printf "\"%s\":\"%s\"\n" "latest_fw" "$LATEST_FW"
  printf "}"

elif [ "$VAL" == "upgrade" ]; then

  MODEL_SUFFIX=$(cat $YI_HACK_PREFIX/model_suffix)
  FW_VERSION=$(cat $YI_HACK_PREFIX/version)
  LATEST_FW=$($YI_HACK_PREFIX/usr/bin/wget -O - https://api.github.com/repos/roleoroleo/yi-hack-Allwinner/releases/latest 2>&1 | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  if [ "$FW_VERSION" == "$LATEST_FW" ]; then
    printf "Content-type: text/html\r\n\r\n"
    printf "No new firmware available."
    exit
  fi

  GITHUB_FIRMWARE_URL=https://github.com/roleoroleo/yi-hack-Allwinner/releases/download/$LATEST_FW/${MODEL_SUFFIX}_${LATEST_FW}.tgz
  $YI_HACK_PREFIX/script/pull_and_install_firmware.sh "$GITHUB_FIRMWARE_URL"

fi
