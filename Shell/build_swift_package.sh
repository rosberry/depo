#!/bin/sh

set -e

BUILD_DIR=$1
TARGET_NAME=$2
PACKAGE_NAME=${3:-$(basename "$PWD")}

xcodeprojects_count=`ls -1 -d *.xcodeproj | wc -l`
if [ $xcodeprojects_count == 0 ]; then
  chmod -R +rw .
  swift package generate-xcodeproj
fi

xcodebuild \
  -target $TARGET_NAME \
  -configuration Release \
  defines_module=yes \
  -sdk "iphoneos" archive \
  -quiet \
  PRODUCT_NAME=$TARGET_NAME

xcodebuild \
  -target $TARGET_NAME \
  -configuration Release \
  only_active_arch=no \
  defines_module=yes \
  -arch x86_64 \
  -sdk "iphonesimulator" archive \
  -quiet \
  PRODUCT_NAME=$TARGET_NAME

IPHONE_DIR="${BUILD_DIR}/${PACKAGE_NAME}/Release-iphoneos"
SIMULATOR_DIR="${BUILD_DIR}/${PACKAGE_NAME}/Release-iphonesimulator"
mkdir -p $IPHONE_DIR $SIMULATOR_DIR
cp -r build/Release-iphoneos/* $IPHONE_DIR
cp -r build/Release-iphonesimulator/* $SIMULATOR_DIR
