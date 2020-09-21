#!/bin/sh

set -e

DEVELOPMENT_TEAM=$1

xcodebuild \
-configuration Release \
-arch arm64 \
-arch armv7 \
-arch armv7s \
only_active_arch=no defines_module=yes \
-sdk "iphoneos" archive \
DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM

xcodebuild \
-configuration Release \
-arch x86_64 \
-arch i386 \
only_active_arch=no \
defines_module=yes \
-sdk "iphonesimulator" archive \
DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM

