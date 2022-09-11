#!/bin/bash

#
# Copyright (c) 2022 WooJin Kong. All Right Reserved
#
# PaperMC update bash script
#

force_download=false
output_name="paper.jar"

usage() {
  echo "Usage: $0 [ -v VERSION ] [ -f ] [ -o OUTPUT]" 1>&2 
}

while getopts ":v:o:f" options; do 
  case "${options}" in
    v)
      version=${OPTARG}
      ;;
    o)
      output_name=${OPTARG}
      if [[ ${OPTARG} != *".jar" ]]; then
        output_name="${output_name}.jar"
      fi
      ;;
    f)
      force_download=true
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit 1
      ;;
    *)
      ;;
  esac
done

check_opt(){
  if [ "$version" = "" ]; then
    echo "Error: -v required."
    usage
    exit 1
  fi
}

check_file(){
  if [ ! -f ./current-build ]; then
    touch current-build
  fi
}

get_cur_build(){
  cur_build=$(cat current-build)
  echo $cur_build
}

get_latest_build(){
  raw_json=$(curl -s -X GET "https://papermc.io/api/v2/projects/paper/versions/$version" -H  "accept: application/json")
  if [ $(echo $raw_json | jq 'has("error")') = true ]; then
    echo ""
  else
    latest_build=$(echo $raw_json | jq '.builds[]' | tail -1)
    echo $latest_build
  fi
}

get_oldsum(){
  if [ -f ./$output_name ]; then
    oldsum=$(sha256sum $output_name | awk '{print $1}')
  else
    oldsum=""
  fi
  echo $oldsum
}

get_newsum(){
  newsum=$(curl -s -X GET "https://papermc.io/api/v2/projects/paper/versions/$version/builds/$latest_build" -H  "accept: application/json" | jq '.downloads.application.sha256' | sed 's/"//g')
  echo $newsum
}

check_need_update(){
  if [ "$force_download" = true ]; then
  echo "Force downloading..."
    download_latest
  else
    if [ "$1" != "$2" ] || [ "$cur_build" != "$latest_build" ]; then
      download_latest
    else
      echo "Already up-to-date"
    fi
  fi
}

download_latest(){
    echo "Downloading paper-$version-$latest_build.jar..."
    wget -q --show-progress https://papermc.io/api/v2/projects/paper/versions/$version/builds/$latest_build/downloads/paper-$version-$latest_build.jar -O $output_name
    echo $latest_build > current-build
}

check_opt
check_file
cur_build=$(get_cur_build)
latest_build=$(get_latest_build)

if [ "$latest_build" = "" ]; then
  echo "Version not found!"
  exit
fi

echo "Current build is \"$cur_build\""
echo "Latest build is \"$latest_build\""
check_need_update $(get_oldsum) $(get_newsum)
