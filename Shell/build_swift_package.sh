#!/bin/sh

set -e

DEVELOPMENT_TEAM=$1
BUILD_DIR=$2
PACKAGE_NAME=${3:-$(basename "$PWD")}

xcodebuild \
-configuration Release \
only_active_arch=no \
defines_module=yes \
-sdk "iphoneos" archive \
DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM \
-quiet

xcodebuild \
-configuration Release \
only_active_arch=no \
defines_module=yes \
-sdk "iphonesimulator" archive \
DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM \
-quiet

IPHONE_DIR="${BUILD_DIR}/${PACKAGE_NAME}/Release-iphoneos"
SIMULATOR_DIR="${BUILD_DIR}/${PACKAGE_NAME}/Release-iphonesimulator"
mkdir -p $IPHONE_DIR $SIMULATOR_DIR
cp -r build/Release-iphoneos/* $IPHONE_DIR
cp -r build/Release-iphonesimulator/* $SIMULATOR_DIR
