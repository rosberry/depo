#!/bin/sh

set -e

BUILD_DIR=$1
SCHEME=$2
PACKAGE_NAME=${3:-$(basename "$PWD")}

CONFIGURATION='Release'
DERIVED_DATA_PATH='build'

xcodeprojects_count=`ls -1 -d *.xcodeproj | wc -l`
if [ $xcodeprojects_count == 0 ]; then
  swift package generate-xcodeproj
fi

xcodebuild \
  -scheme $SCHEME \
  -configuration $CONFIGURATION \
  defines_module=yes \
  -sdk "iphoneos" \
  -quiet \
  -derivedDataPath $DERIVED_DATA_PATH

xcodebuild \
  -scheme $SCHEME \
  -configuration $CONFIGURATION \
  only_active_arch=no \
  defines_module=yes \
  -arch x86_64 \
  -sdk "iphonesimulator" \
  -quiet \
  -derivedDataPath $DERIVED_DATA_PATH

IPHONE_DIR="${BUILD_DIR}/${PACKAGE_NAME}/${CONFIGURATION}-iphoneos"
SIMULATOR_DIR="${BUILD_DIR}/${PACKAGE_NAME}/${CONFIGURATION}-iphonesimulator"
mkdir -p $IPHONE_DIR $SIMULATOR_DIR
cp -r `echo "${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphoneos/*"` $IPHONE_DIR
cp -r `echo "${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphonesimulator/*"` $SIMULATOR_DIR
