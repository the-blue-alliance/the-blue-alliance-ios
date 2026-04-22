#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

usage() {
    cat <<EOF
Usage: $0 [--fix] [--strict]

  (no args)   Lint Swift files (warnings only, exits 0 even on violations).
  --strict    Lint Swift files; exit non-zero on any violation (matches CI).
  --fix       Format Swift files in place.

--fix and --strict are mutually exclusive.
EOF
}

MODE="lint"
STRICT=""

for arg in "$@"; do
    case "$arg" in
        --fix)
            MODE="fix"
            ;;
        --strict)
            STRICT="--strict"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ "$MODE" = "fix" ] && [ -n "$STRICT" ]; then
    echo "--fix and --strict cannot be combined" >&2
    exit 1
fi

if [ "$MODE" = "fix" ]; then
    xcrun swift-format format --in-place --parallel --recursive the-blue-alliance-ios Packages
else
    xcrun swift-format lint --recursive $STRICT the-blue-alliance-ios Packages
fi
