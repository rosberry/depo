#!/bin/sh

# Set bash script to exit immediately if any commands fail.
set -e

FRAMEWORK_NAME=$1
OUTPUT_PATH="./Build/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework"

# If remnants from a previous build exist, delete them.
if [ -d "../build" ]; then
  rm -rf "../build"
fi

# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos" archive
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator" archive

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
lipo -create -output "${OUTPUT_PATH}/${FRAMEWORK_NAME}" "../build/Release-iphoneos/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "../build/Release-iphonesimulator/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

# Copy the Swift module mappings for the simulator into the
# framework.  The device mappings already exist from step 6.
cp -r "../build/Release-iphonesimulator/${FRAMEWORK_NAME}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/" "${OUTPUT_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule"

# Delete the most recent build.
if [ -d "../build" ]; then
  rm -rf "../build"
fi
