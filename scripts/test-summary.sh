#!/bin/sh
# Summarize an .xcresult bundle.
#
# xcodebuild's exit code is what decides pass/fail; this only reports. It reads
# the result bundle rather than a JUnit file because swift-testing runs are not
# represented in the JUnit output xcodebuild-era tooling produces.
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path/to/Something.xcresult>" >&2
    exit 1
fi

BUNDLE="$1"

if [ ! -e "$BUNDLE" ]; then
    echo "No result bundle at $BUNDLE" >&2
    exit 1
fi

xcrun xcresulttool get test-results summary --path "$BUNDLE" --format json \
    | python3 -c '
import json
import os
import sys

summary = json.load(sys.stdin)
title = summary.get("title", "Tests")
total = summary.get("totalTestCount", 0)
passed = summary.get("passedTests", 0)
failed = summary.get("failedTests", 0)
skipped = summary.get("skippedTests", 0)
result = summary.get("result", "Unknown")

print(f"{title}: {result} - {passed}/{total} passed, {failed} failed, {skipped} skipped")

failures = summary.get("testFailures") or []
on_ci = os.environ.get("GITHUB_ACTIONS") == "true"

for failure in failures:
    name = failure.get("testName") or failure.get("targetName") or "Unknown test"
    message = (failure.get("failureText") or "").strip().replace("\n", " ")
    print(f"  {name}: {message}")
    if on_ci:
        print(f"::error title={name}::{message}")
'
