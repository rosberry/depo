#!/bin/sh

set -e

FRAMEWORK_NAME=$1

xcodebuild \
-target "${FRAMEWORK_NAME}" \
-configuration Release \
only_active_arch=no \
defines_module=yes \
-sdk "iphoneos" archive \
-quiet

xcodebuild \
-target "${FRAMEWORK_NAME}" \
-configuration Release \
only_active_arch=no \
defines_module=yes \
-sdk "iphonesimulator" archive \
-quiet
