#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

xcrun swift-format format --in-place --parallel --recursive the-blue-alliance-ios Packages
