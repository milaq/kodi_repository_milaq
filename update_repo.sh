#!/bin/bash

set -e
mkdir -p tmp/

function get_addon_data_github {
  kodi_name=$1
  repo_name=$2
  version=$3
  mkdir -p pool/$kodi_name/
  wget https://github.com/$repo_name/archive/$version.zip -O tmp/addon.zip
  mv tmp/addon.zip pool/$kodi_name/$kodi_name-$version.zip
  wget https://raw.githubusercontent.com/$repo_name/$version/addon.xml -O tmp/addon.xml
  cat tmp/addon.xml | tail -n +2 >> addons.xml
}

function gen_xml_header {
  echo "<?xml version="1.0" encoding="UTF-8" standalone="yes"?>" > addons.xml
  echo "<addons>" >> addons.xml
}

function gen_xml_footer {
  echo "</addons>" >> addons.xml
}

function gen_checksum {
  md5sum addons.xml | awk '{print $1}' > addons.xml.md5
}

function get_repo_data {
  kodi_name=$1
  version=$2
  mkdir -p pool/$kodi_name/
  pushd dist
  zip -o -r ../pool/$kodi_name/$kodi_name-$version.zip $kodi_name/
  popd
  cat dist/$kodi_name/addon.xml > tmp/addon.xml
  cat tmp/addon.xml | tail -n +2 >> addons.xml
}

gen_xml_header

get_repo_data repository.milaq 1.0.0
get_addon_data_github service.blackbarsremover milaq/kodi_addon_blackbarsremover 2.1.1
get_addon_data_github screensaver.fanart.slideshow milaq/kodi_screensaver_fanart_slideshow 0.9.0

gen_xml_footer
gen_checksum

echo
echo --------------------------------------
echo Kodi repository generation successful.
echo
