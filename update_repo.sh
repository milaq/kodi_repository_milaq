#!/bin/bash

set -e
set -o pipefail

REPO_NAME=repository.milaq
REPO_VERSION=3.0.0

function get_addon_data_github {
  kodi_version=$1
  package_name=$2
  repo_name=$3
  shift; shift; shift
  versions=$@
  mkdir -p dists/$kodi_version/$package_name/
  for version in $versions; do
    echo "Getting addon data for $package_name ($version)..."
    if [[ ! -f dists/$kodi_version/$package_name/$package_name-$version.zip ]]; then
      wget -q https://github.com/$repo_name/archive/$version.zip -O dists/$kodi_version/$package_name/$package_name-$version.zip
    fi
    unzip -p "dists/$kodi_version/$package_name/$package_name-$version.zip" "*/addon.xml" | tail -n +2 >> dists/$kodi_version/addons.xml
  done
}

function get_self_repo_data {
  kodi_version=$1
  mkdir -p dists/$kodi_version/$REPO_NAME/
  cp $REPO_NAME-$REPO_VERSION.zip dists/$kodi_version/$REPO_NAME/
  cat $REPO_NAME/addon.xml | tail -n +2 >> dists/$kodi_version/addons.xml
}

function gen_xml_header {
  kodi_version=$1
  echo "<?xml version=/"1.0/" encoding=/"UTF-8/" standalone=/"yes/"?>" > dists/$kodi_version/addons.xml
  echo "<addons>" >> dists/$kodi_version/addons.xml
}

function gen_xml_footer {
  kodi_version=$1
  echo "</addons>" >> dists/$kodi_version/addons.xml
}

function gen_checksum {
  kodi_version=$1
  md5sum dists/$kodi_version/addons.xml | awk '{print $1}' > dists/$kodi_version/addons.xml.md5
}

function gen_repoarchive {
  zip -r $REPO_NAME-$REPO_VERSION.zip $REPO_NAME/
}

echo "Generating repo archive..."
gen_repoarchive

echo "Generating repo data for Kodi Leia..."
mkdir -p dists/leia
gen_xml_header leia
get_self_repo_data leia
get_addon_data_github leia service.blackbarsremover milaq/kodi_addon_blackbarsremover "2.0.1" "2.1.0" "2.1.1"
get_addon_data_github leia resource.uisounds.nebula.mlq milaq/kodi_uisounds_nebula_mlq "1.0.0"
get_addon_data_github leia screensaver.fanart.slideshow milaq/kodi_screensaver_fanart_slideshow "0.9.5" "0.9.6"
get_addon_data_github leia service.odroid.screenoff milaq/kodi_addon_odroid_screenoff "1.0.0" "1.0.1" "1.1.0"
gen_xml_footer leia
gen_checksum leia

echo "Generating repo data for Kodi Matrix..."
mkdir -p dists/matrix
gen_xml_header matrix
get_self_repo_data matrix
get_addon_data_github matrix service.blackbarsremover milaq/kodi_addon_blackbarsremover "3.0.0" "3.1.0" "3.2.0"
get_addon_data_github matrix resource.uisounds.nebula.mlq milaq/kodi_uisounds_nebula_mlq "1.0.0"
get_addon_data_github matrix screensaver.fanart.slideshow milaq/kodi_screensaver_fanart_slideshow "0.9.6"
get_addon_data_github matrix service.odroid.screenoff milaq/kodi_addon_odroid_screenoff "1.1.0"
gen_xml_footer matrix
gen_checksum matrix

echo
echo --------------------------------------
echo Kodi repository generation successful.
echo
