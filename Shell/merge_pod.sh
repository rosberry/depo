#!/bin/sh

set -e

SCHEMA_NAME=$1
PRODUCT_NAME=$2
OUTPUT_DIR=${3:-"."}
BUILD_DIR=${4:-"."}

OUTPUT_PATH="${OUTPUT_DIR}/Build/iOS/${PRODUCT_NAME}.framework"

IPHONEOS_FRAMEWORK_DIR="${BUILD_DIR}/Release-iphoneos/${SCHEMA_NAME}/${PRODUCT_NAME}.framework"
SIMULATOR_FRAMEWORK_DIR="${BUILD_DIR}/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework"
if [ -d $IPHONEOS_FRAMEWORK_DIR ]; then
  mkdir -p "${OUTPUT_PATH}"
  cp -a $IPHONEOS_FRAMEWORK_DIR/ "${OUTPUT_PATH}"
else
  echo $PWD $IPHONEOS_FRAMEWORK_DIR
  echo $PWD $SIMULATOR_FRAMEWORK_DIR
  echo "No frameworks at ${PWD}/${BUILD_DIR}"
  exit 1
fi

xcrun lipo -create \
-output \
"${OUTPUT_PATH}/${PRODUCT_NAME}" \
$IPHONEOS_FRAMEWORK_DIR/$PRODUCT_NAME \
$SIMULATOR_FRAMEWORK_DIR/$PRODUCT_NAME

SWIFTMODULE_PATH="${BUILD_DIR}/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/Modules/${PRODUCT_NAME}.swiftmodule/"
if [ -d $SWIFTMODULE_PATH ]; then
  cp -r "${SWIFTMODULE_PATH}" "${OUTPUT_PATH}/Modules/${PRODUCT_NAME}.swiftmodule"
fi

