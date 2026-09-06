#!/bin/bash
#
# Generates the app icon previews shown in the Settings app icon picker.
#
# Icon Composer (.icon) files cannot be loaded at runtime with UIImage(named:) — UIKit
# throws "Need an imageRef" because they have no raster representation. Each icon
# therefore ships a matching <Name>Preview image set, rendered here from the icon itself.
#
# Icons render differently in light and dark appearance (the default icon, for example,
# is indigo-on-white in light and near-black in dark), so each preview ships both and
# lets the asset catalog pick — otherwise the picker disagrees with the Home Screen.
#
# By default only icons whose preview is missing or out of date are rendered, so this is
# cheap enough to run on every build. It runs as the "Generate App Icon Previews" build
# phase; run it by hand if you want the result staged before building.
#
#   --force   re-render every icon, even if its preview looks current
#   --check   report what is stale without writing anything (exits 1 if stale)

set -euo pipefail

cd "$(dirname "$0")/.."

SCRIPTS_DIR="scripts"
ICONS_DIR="the-blue-alliance-ios/AppIcons"
PREVIEWS_DIR="the-blue-alliance-ios/Assets.xcassets/AppIconPreviews"
PROJECT="the-blue-alliance-ios.xcodeproj/project.pbxproj"
PREVIEW_SIZE=180

# Xcode exports the resolved value when this runs as a build phase. Falling back to the
# project file keeps manual runs working, and keeps this in step with the app when the
# deployment target is bumped.
deployment_target() {
    if [ -n "${IPHONEOS_DEPLOYMENT_TARGET:-}" ]; then
        echo "$IPHONEOS_DEPLOYMENT_TARGET"
        return
    fi
    local target
    target="$(grep -oE 'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+' "$PROJECT" \
        | awk '{ print $3 }' | sort -uV | head -1)"
    if [ -z "$target" ]; then
        echo "error: could not determine IPHONEOS_DEPLOYMENT_TARGET from $PROJECT" >&2
        exit 1
    fi
    echo "$target"
}

# The app target names its primary icon; everything else is an alternate. Deriving this
# rather than taking the first glob match keeps the designation correct no matter what
# a new icon is called.
primary_icon_name() {
    if [ -n "${ASSETCATALOG_COMPILER_APPICON_NAME:-}" ]; then
        echo "$ASSETCATALOG_COMPILER_APPICON_NAME"
        return
    fi
    local name
    name="$(grep -oE 'ASSETCATALOG_COMPILER_APPICON_NAME = [A-Za-z0-9_]+' "$PROJECT" \
        | awk '{ print $3 }' | sort -u | head -1)"
    if [ -z "$name" ]; then
        echo "error: could not determine ASSETCATALOG_COMPILER_APPICON_NAME from $PROJECT" >&2
        exit 1
    fi
    echo "$name"
}

MODE="${1:-}"

# Every icon ships two previews: a light one the asset catalog uses by default, and a
# dark one tagged with the luminosity appearance. These four helpers are the only place
# the naming convention lives, so it stays consistent everywhere it's referenced.
image_set_for() {
    echo "$PREVIEWS_DIR/${1}Preview.imageset"
}

light_preview_filename_for() {
    echo "${1}Preview.png"
}

dark_preview_filename_for() {
    echo "${1}Preview-dark.png"
}

preview_paths_for() {
    local name="$1" image_set
    image_set="$(image_set_for "$name")"
    echo "$image_set/$(light_preview_filename_for "$name")"
    echo "$image_set/$(dark_preview_filename_for "$name")"
}

# An icon is stale when either preview is missing, or when anything inside the .icon
# bundle has been modified more recently than the light preview we generated from it.
is_stale() {
    local icon_path="$1" name light_preview dark_preview
    name="$(basename "$icon_path" .icon)"
    { read -r light_preview; read -r dark_preview; } < <(preview_paths_for "$name")

    if [ ! -e "$light_preview" ] || [ ! -e "$dark_preview" ]; then
        return 0
    fi
    # Both previews are written together, so the light one stands in for the pair.
    if [ -n "$(find "$icon_path" -newer "$light_preview" -print -quit)" ]; then
        return 0
    fi
    return 1
}

# Previews whose icon no longer exists, so removing an icon can't leave art behind.
orphaned_previews() {
    local image_set preview_name
    for image_set in "$PREVIEWS_DIR"/*Preview.imageset; do
        [ -e "$image_set" ] || continue
        preview_name="$(basename "$image_set" .imageset)"
        [ -d "$ICONS_DIR/${preview_name%Preview}.icon" ] || echo "$image_set"
    done
}

if [ "$MODE" = "--check" ]; then
    stale=0
    for icon_path in "$ICONS_DIR"/*.icon; do
        if is_stale "$icon_path"; then
            echo "$(basename "$icon_path") is out of date"
            stale=1
        fi
    done
    while IFS= read -r image_set; do
        [ -n "$image_set" ] || continue
        echo "$(basename "$image_set") has no matching icon"
        stale=1
    done <<< "$(orphaned_previews)"
    if [ "$stale" -eq 0 ]; then
        echo "App icon previews are up to date."
    else
        echo "Run scripts/generate-app-icon-previews.sh to update them."
    fi
    exit "$stale"
fi

# Work out what needs rendering before doing any expensive work.
stale_icons=()
for icon_path in "$ICONS_DIR"/*.icon; do
    if [ "$MODE" = "--force" ] || is_stale "$icon_path"; then
        stale_icons+=("$icon_path")
    fi
done

orphans="$(orphaned_previews)"

if [ "${#stale_icons[@]}" -eq 0 ] && [ -z "$orphans" ]; then
    echo "App icon previews are up to date."
    exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# The composed renditions only exist inside a compiled catalog, so build one containing
# every icon, then read the appearances back out of it.
compile_catalog() {
    local target primary
    target="$(deployment_target)"
    primary="$(primary_icon_name)"
    local args=(--compile "$TMP_DIR/car" --platform iphoneos
        --minimum-deployment-target "$target" --include-all-app-icons
        --output-partial-info-plist "$TMP_DIR/partial.plist")
    local name
    for icon_path in "$ICONS_DIR"/*.icon; do
        name="$(basename "$icon_path" .icon)"
        if [ "$name" = "$primary" ]; then
            args+=(--app-icon "$name")
        else
            args+=(--alternate-app-icon "$name")
        fi
    done
    for icon_path in "$ICONS_DIR"/*.icon; do
        args+=("$icon_path")
    done
    mkdir -p "$TMP_DIR/car"
    xcrun actool "${args[@]}" > /dev/null
}

# The extractor is a macOS host tool, but Xcode exports the *target's* build settings
# into script phases — including SDKROOT and IPHONEOS_DEPLOYMENT_TARGET. Clang honors
# both, which retargets this compile at iOS, where AppKit does not exist. Clear them for
# this one invocation and pin the macOS SDK explicitly. Keep clang's output so a genuine
# compile error isn't reduced to a bare "could not build".
build_extractor() {
    env -u SDKROOT -u IPHONEOS_DEPLOYMENT_TARGET -u MACOSX_DEPLOYMENT_TARGET \
        xcrun --sdk macosx clang -fobjc-arc -O2 \
        -framework Foundation -framework AppKit -framework CoreGraphics -framework ImageIO \
        -o "$TMP_DIR/extractor" "$SCRIPTS_DIR/AppIconPreviewExtractor.m" \
        > "$TMP_DIR/clang.log" 2>&1
}

write_contents_json() {
    local image_set="$1" name="$2"
    cat > "$image_set/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "$(light_preview_filename_for "$name")",
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "$(dark_preview_filename_for "$name")",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "template-rendering-intent" : "original"
  }
}
JSON
}

if [ "${#stale_icons[@]}" -gt 0 ]; then
    compile_catalog
    if ! build_extractor; then
        echo "error: could not build $SCRIPTS_DIR/AppIconPreviewExtractor.m" >&2
        [ -s "$TMP_DIR/clang.log" ] && cat "$TMP_DIR/clang.log" >&2
        exit 1
    fi

    mkdir -p "$PREVIEWS_DIR"
    cat > "$PREVIEWS_DIR/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

    for icon_path in "${stale_icons[@]}"; do
        name="$(basename "$icon_path" .icon)"
        image_set="$(image_set_for "$name")"
        { read -r light_preview; read -r dark_preview; } < <(preview_paths_for "$name")
        mkdir -p "$image_set"

        "$TMP_DIR/extractor" "$TMP_DIR/car/Assets.car" "$name" UIAppearanceAny \
            "$TMP_DIR/$name-light.png" > /dev/null
        "$TMP_DIR/extractor" "$TMP_DIR/car/Assets.car" "$name" UIAppearanceDark \
            "$TMP_DIR/$name-dark.png" > /dev/null

        sips -Z "$PREVIEW_SIZE" "$TMP_DIR/$name-light.png" --out "$light_preview" > /dev/null
        sips -Z "$PREVIEW_SIZE" "$TMP_DIR/$name-dark.png" --out "$dark_preview" > /dev/null

        write_contents_json "$image_set" "$name"
        echo "generated $(basename "$image_set") (light + dark)"
    done
fi

while IFS= read -r image_set; do
    [ -n "$image_set" ] || continue
    rm -rf "$image_set"
    echo "removed stale $(basename "$image_set" .imageset)"
done <<< "$orphans"
