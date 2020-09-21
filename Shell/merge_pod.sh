#!/bin/sh

set -e

SCHEMA_NAME=$1
PRODUCT_NAME=$2
OUTPUT_DIR=${$3:="."}
BUILD_DIR=${$4:="."}

OUTPUT_PATH="${OUTPUT_DIR}/Build/iOS/${PRODUCT_NAME}.framework"

IPHONEOS_FRAMEWORK_DIR="${BUILD_DIR}/build/Release-iphoneos/${SCHEMA_NAME}/${PRODUCT_NAME}.framework"
SIMULATOR_FRAMEWORK_DIR="${BUILD_DIR}/build/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
if [[ -d $IPHONEOS_FRAMEWORK_DIR ] && [ -d $SIMULATOR_FRAMEWORK_DIR ]]; then
  mkdir -p "${OUTPUT_PATH}"
  cp -a $IPHONEOS_FRAMEWORK_DIR "${OUTPUT_PATH}"
else
  echo "No frameworks at ${BUILD_DIR}/build"
  exit 1
fi

xcrun lipo -create \
-output \
"${OUTPUT_PATH}/${PRODUCT_NAME}" \
$IPHONEOS_FRAMEWORK_DIR \
$SIMULATOR_FRAMEWORK_DIR

SWIFTMODULE_PATH="${BUILD_DIR}/build/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/Modules/${SCHEMA_NAME}.swiftmodule/"
if [ -f $SWIFTMODULE_PATH ]; then
  cp -r "${SWIFTMODULE_PATH}" "${OUTPUT_PATH}/Modules/${SCHEMA_NAME}.swiftmodule"
fi
