#!/bin/sh

# Set bash script to exit immediately if any commands fail.
set -e

FRAMEWORK_NAME=$1

# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos" archive
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator" archive
