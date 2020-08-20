#!/bin/sh

FRAMEWORK_NAME=$1
OUTPUT_PATH="./Build/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework"

# Remove .framework file if exists on Desktop from previous run.
if [ -d "${OUTPUT_PATH}" ]; then
  rm -rf "${OUTPUT_PATH}"
fi

# Copy the device version of framework to OUTPUT_PATH.
mkdir -p "${OUTPUT_PATH}"
cp -a "../build/Release-iphoneos/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/." "${OUTPUT_PATH}"

# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.

xcrun lipo -create -output "${OUTPUT_PATH}/${FRAMEWORK_NAME}" "../build/Release-iphoneos/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "../build/Release-iphonesimulator/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 6.
SWIFTMODULE_PATH="../build/Release-iphonesimulator/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/"
if [ -f $SWIFTMODULE_PATH ]; then
  cp -r "${SWIFTMODULE_PATH}" "${OUTPUT_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule"
fi

exit 0

# Delete the most recent build.
if [ -d "../build" ]; then
  rm -rf "../build"
fi

