#!/bin/sh

set -e

SCHEMA_NAME=$1
BUILD_DIR=${2:-"."}

OUTPUT_PATH="${BUILD_DIR}/Build/iOS/"

FRAMEWORK_DIR="${SCHEMA_NAME}/"

cp -r $(find $FRAMEWORK_DIR -type d -name "*.framework") $OUTPUT_PATH
cp -r $(find $FRAMEWORK_DIR -type d -name "*.bundle") $OUTPUT_PATH
