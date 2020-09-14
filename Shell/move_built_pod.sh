#!/bin/sh

set -e

SCHEMA_NAME=$1

OUTPUT_PATH="./Build/iOS/"

FRAMEWORK_DIR="${SCHEMA_NAME}/"

cp -r $(find $FRAMEWORK_DIR -type d -name "*.framework") $OUTPUT_PATH
cp -r $(find $FRAMEWORK_DIR -type d -name "*.bundle") $OUTPUT_PATH
