#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

usage() {
    cat <<USAGE
Usage: $0 [--fix] [--strict]

  (no args)   Lint Swift files (warnings only, exits 0 even on violations).
  --strict    Lint Swift files; exit non-zero on any violation (matches CI).
  --fix       Format Swift files in place.

--fix and --strict are mutually exclusive.
USAGE
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

# Ask git for the Swift files instead of naming directories, so a new target or
# package is covered the day it lands. --others picks up files that aren't
# committed yet; --exclude-standard keeps .gitignore'd build output out. -z
# because some paths contain spaces.
swift_files() {
    git ls-files -z --cached --others --exclude-standard -- '*.swift'
}

# xargs runs nothing on empty input, so a broken discovery would exit 0 having
# checked nothing. Fail loudly instead.
if [ "$(swift_files | tr -dc '\0' | wc -c)" -eq 0 ]; then
    echo "No Swift files found. Is this a git checkout?" >&2
    exit 1
fi

if [ "$MODE" = "fix" ]; then
    swift_files | xargs -0 xcrun swift-format format --in-place --parallel
else
    swift_files | xargs -0 xcrun swift-format lint --parallel $STRICT
fi
