#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "requests",
# ]
# ///
"""Refresh Packages/TBAAPI/Sources/TBAAPI/openapi.json from prod.

Downloads the latest TBA API v3 swagger from
https://www.thebluealliance.com/swagger/api_v3.json and patches out
`oneOf`/`anyOf` branches whose only job is to express nullability via
`{"type": "null"}` — a shape that's valid OpenAPI 3.1 but unsupported by
swift-openapi-generator (see apple/swift-openapi-generator#817, which
endorses dropping the null branch as the proper workaround).

Run: uv run scripts/update-apiv3-spec.py
"""

from __future__ import annotations

import json
import pathlib
import sys

import requests

SPEC_URL = "https://www.thebluealliance.com/swagger/api_v3.json"
OUT_PATH = (
    pathlib.Path(__file__).resolve().parent.parent
    / "Packages"
    / "TBAAPI"
    / "Sources"
    / "TBAAPI"
    / "openapi.json"
)


def _is_null_branch(node: object) -> bool:
    return isinstance(node, dict) and node == {"type": "null"}


def _strip_null_compositions(
    node: object,
    path: list[str],
    patches: list[str],
    nullified_properties: set[tuple[str, ...]],
) -> object:
    """Recursively strip `{"type":"null"}` branches from `oneOf`/`anyOf`.

    After filtering, if only one branch remains the composition collapses
    to that branch (merging any non-composition siblings like `description`).

    When the stripped node lives under a `properties/<name>` parent, we record
    `(parent_path_tuple, name)` so a second pass can drop the name from the
    parent schema's `required` list — otherwise a field that was "required
    but nullable" upstream collapses to "required and non-null," which breaks
    decoding for historical records that legitimately send `null`.
    """
    if isinstance(node, dict):
        for keyword in ("oneOf", "anyOf"):
            branches = node.get(keyword)
            if not isinstance(branches, list):
                continue
            filtered = [b for b in branches if not _is_null_branch(b)]
            if len(filtered) == len(branches):
                continue
            patches.append("/".join(path) + f" ({keyword})")
            if len(path) >= 2 and path[-2] == "properties":
                parent_path = tuple(path[:-2])
                nullified_properties.add(parent_path + (path[-1],))
            siblings = {k: v for k, v in node.items() if k != keyword}
            if len(filtered) == 1:
                keep = filtered[0]
                merged = {**siblings, **keep} if isinstance(keep, dict) else keep
                return _strip_null_compositions(
                    merged, path, patches, nullified_properties
                )
            return _strip_null_compositions(
                {**siblings, keyword: filtered}, path, patches, nullified_properties
            )
        return {
            k: _strip_null_compositions(v, path + [k], patches, nullified_properties)
            for k, v in node.items()
        }
    if isinstance(node, list):
        return [
            _strip_null_compositions(
                item, path + [str(i)], patches, nullified_properties
            )
            for i, item in enumerate(node)
        ]
    return node


def _drop_nullified_required(
    spec: dict, nullified: set[tuple[str, ...]]
) -> list[str]:
    """Remove nullified property names from their parent schema's `required`.

    Returns a list of "<parent_path>.<field>" strings describing each removal.
    """
    removed: list[str] = []
    for *parent_parts, name in sorted(nullified):
        node: object = spec
        for part in parent_parts:
            if not isinstance(node, dict) or part not in node:
                node = None
                break
            node = node[part]
        if not isinstance(node, dict):
            continue
        required = node.get("required")
        if isinstance(required, list) and name in required:
            node["required"] = [r for r in required if r != name]
            removed.append("/".join(parent_parts) + f".required[-{name}]")
    return removed


def _flatten_score_breakdown_oneof(spec: dict) -> bool:
    """Replace Match.score_breakdown's `oneOf` with a free-form nullable object.

    The upstream oneOf lists eleven per-year schemas with no discriminator, so
    swift-openapi-generator emits a try-each decoder that mis-routes every
    non-2015 match through the 2016 branch, dropping all year-specific fields
    (issues #1023 / #1052). The app already consumes the breakdown as raw
    `[String: Any]`, so we degrade the schema to a free-form object and let
    `OpenAPIObjectContainer` preserve the payload verbatim.
    """
    try:
        sb = spec["components"]["schemas"]["Match"]["properties"]["score_breakdown"]
    except (KeyError, TypeError):
        return False
    if not isinstance(sb, dict) or "oneOf" not in sb:
        return False
    description = sb.get("description")
    replacement: dict = {"type": ["object", "null"]}
    if description:
        replacement = {"description": description, **replacement}
    spec["components"]["schemas"]["Match"]["properties"]["score_breakdown"] = replacement
    return True


def _find_residual_null_compositions(node: object, path: list[str]) -> list[str]:
    """Return paths where a `oneOf`/`anyOf` still contains a null branch."""
    hits: list[str] = []
    if isinstance(node, dict):
        for keyword in ("oneOf", "anyOf"):
            branches = node.get(keyword)
            if isinstance(branches, list) and any(_is_null_branch(b) for b in branches):
                hits.append("/".join(path) + f" ({keyword})")
        for k, v in node.items():
            hits.extend(_find_residual_null_compositions(v, path + [k]))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            hits.extend(_find_residual_null_compositions(item, path + [str(i)]))
    return hits


def main() -> int:
    print(f"Fetching {SPEC_URL}")
    resp = requests.get(SPEC_URL, timeout=30)
    resp.raise_for_status()
    spec = resp.json()

    version = spec.get("info", {}).get("version", "unknown")
    print(f"Upstream version: {version}")

    patches: list[str] = []
    nullified: set[tuple[str, ...]] = set()
    patched = _strip_null_compositions(spec, [], patches, nullified)

    if patches:
        print(f"Patched {len(patches)} null-branch composition(s):")
        for p in patches:
            print(f"  - {p}")
    else:
        print("No null-branch compositions found.")

    required_removals = _drop_nullified_required(patched, nullified)
    if required_removals:
        print(f"Dropped {len(required_removals)} now-nullable field(s) from `required`:")
        for r in required_removals:
            print(f"  - {r}")

    if _flatten_score_breakdown_oneof(patched):
        print("Flattened Match.score_breakdown oneOf to free-form nullable object.")

    OUT_PATH.write_text(json.dumps(patched, indent=2) + "\n")
    print(f"Wrote {OUT_PATH}")

    residual = _find_residual_null_compositions(patched, [])
    if residual:
        print(
            "ERROR: patched spec still contains `oneOf`/`anyOf` branches "
            "with `{\"type\": \"null\"}` at:",
            file=sys.stderr,
        )
        for r in residual:
            print(f"  - {r}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
