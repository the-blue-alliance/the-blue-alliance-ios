#!/usr/bin/env python3
"""Verify remote SPM dependencies declared in more than one manifest agree.

The app target resolves packages through `project.pbxproj`, while each local
package under `Packages/` declares its own. Where both name the same upstream
repo, SwiftPM merges them by identity and intersects the version requirements -
so a mismatched URL reads as "the same package from conflicting locations", and
a raised lower bound in one place silently changes what the other resolves to.

Run from anywhere; exits non-zero and explains the divergence.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PBXPROJ = ROOT / "the-blue-alliance-ios.xcodeproj" / "project.pbxproj"

# Matches one remote package record in project.pbxproj, which looks like:
#
#     isa = XCRemoteSwiftPackageReference;
#     repositoryURL = "https://github.com/firebase/firebase-ios-sdk.git";
#     requirement = {
#         kind = upToNextMajorVersion;
#         minimumVersion = 12.12.1;
#     };
#
# Two-stage on purpose: this grabs the record and hands the requirement body
# over as an opaque string, so PBX_MIN below decides whether it's a kind we
# understand. Anything else falls out via `continue` in main().
PBX_BLOCK = re.compile(
    r"isa = XCRemoteSwiftPackageReference;\s*"
    r'repositoryURL = "(?P<url>[^"]+)";\s*'
    r"requirement = \{(?P<req>[^}]*)\}",
)
# Only `kind = upToNextMajorVersion` and `upToNextMinorVersion` carry a
# minimumVersion. exactVersion/branch/revision pins write a different key and
# are skipped.
PBX_MIN = re.compile(r"minimumVersion = (?P<version>[0-9][0-9A-Za-z.\-+]*)")
# The Package.swift side, e.g.
#     .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0")
# Only the `from:` form is checked - that's the one whose lower bound SwiftPM
# intersects across manifests.
SPM_PACKAGE = re.compile(
    r'\.package\(\s*url:\s*"(?P<url>[^"]+)"\s*,\s*from:\s*"(?P<version>[^"]+)"\s*\)'
)


def identity(url: str) -> str:
    """SwiftPM keys packages by the last path component, minus any `.git`.

    So these three are all one package as far as SwiftPM is concerned, which is
    exactly why declaring it twice with different URLs is a problem:

        https://github.com/google/GoogleSignIn-iOS      -> googlesignin-ios
        https://github.com/google/GoogleSignIn-iOS.git  -> googlesignin-ios
        https://github.com/Google/googlesignin-ios/     -> googlesignin-ios
    """
    return url.rstrip("/").rsplit("/", 1)[-1].removesuffix(".git").lower()


def main() -> int:
    # identity -> list of (source, url, version)
    seen: dict[str, list[tuple[str, str, str]]] = {}

    # Side 1: the app target's own remote dependencies.
    text = PBXPROJ.read_text()
    for match in PBX_BLOCK.finditer(text):
        version = PBX_MIN.search(match.group("req"))
        if version is None:
            continue
        url = match.group("url")
        seen.setdefault(identity(url), []).append(
            (PBXPROJ.name, url, version.group("version"))
        )

    # Side 2: every local package's own remote dependencies.
    for manifest in sorted((ROOT / "Packages").glob("*/Package.swift")):
        for match in SPM_PACKAGE.finditer(manifest.read_text()):
            url = match.group("url")
            seen.setdefault(identity(url), []).append(
                (
                    str(manifest.relative_to(ROOT)),
                    url,
                    match.group("version"),
                )
            )

    # Only packages naming the same upstream from two places can conflict; a
    # package declared once is free to say whatever it likes.
    problems = []
    for package, entries in sorted(seen.items()):
        if len(entries) < 2:
            continue
        # Same identity, different URLs: SwiftPM refuses to resolve at all.
        if len({url for _, url, _ in entries}) > 1:
            problems.append(
                f"{package}: declared with different URLs, which SwiftPM reads as "
                "the same package from conflicting locations\n"
                + "\n".join(f"    {src}: {url}" for src, url, _ in entries)
            )
        # Same identity, different floors: resolves, but to the higher floor,
        # silently changing what the other manifest gets.
        if len({version for _, _, version in entries}) > 1:
            problems.append(
                f"{package}: declared with different minimum versions\n"
                + "\n".join(f"    {src}: {version}" for src, _, version in entries)
            )

    if problems:
        print("Dependency pins disagree:\n", file=sys.stderr)
        for problem in problems:
            print(f"  {problem}\n", file=sys.stderr)
        return 1

    # The count is the canary: if a pbxproj format change stops PBX_BLOCK from
    # matching, this drops to 0 rather than the script reporting a real pass.
    shared = sum(1 for entries in seen.values() if len(entries) > 1)
    print(f"Dependency pins agree ({shared} declared in more than one manifest).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
