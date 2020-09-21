#!/bin/sh

set -e

SCHEMA_NAME=$1
PRODUCT_NAME=$2

OUTPUT_PATH="./Build/iOS/${PRODUCT_NAME}.framework"

# Copy the device version of framework to OUTPUT_PATH.
IPHONEOS_FRAMEWORK_DIR="../build/Release-iphoneos/${SCHEMA_NAME}/${PRODUCT_NAME}.framework"
if [ -d $IPHONEOS_FRAMEWORK_DIR ]; then
  mkdir -p "${OUTPUT_PATH}"
  cp -a $IPHONEOS_FRAMEWORK_DIR "${OUTPUT_PATH}"
else
  echo "${IPHONEOS_FRAMEWORK_DIR} does not exist"
  exit 1
fi

# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.


xcrun lipo -create
-output
"${OUTPUT_PATH}/${PRODUCT_NAME}"
"../build/Release-iphoneos/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"
"../build/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/${PRODUCT_NAME}"

# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 6.
SWIFTMODULE_PATH="../build/Release-iphonesimulator/${SCHEMA_NAME}/${PRODUCT_NAME}.framework/Modules/${SCHEMA_NAME}.swiftmodule/"
if [ -f $SWIFTMODULE_PATH ]; then
  cp -r "${SWIFTMODULE_PATH}" "${OUTPUT_PATH}/Modules/${SCHEMA_NAME}.swiftmodule"
fi
