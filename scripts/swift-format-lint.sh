#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

STRICT=""
if [ "${1:-}" = "--strict" ]; then
    STRICT="--strict"
fi

xcrun swift-format lint --recursive $STRICT the-blue-alliance-ios Packages
