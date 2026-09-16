The Blue Alliance for iOS uses GitHub Actions for linting, testing, shipping TestFlight builds, and shipping App Store builds. The workflows live in [`.github/workflows/`](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/main/.github/workflows):

- `pull_request.yml` — runs `swift-format --strict` and the test suite on PRs.
- `push.yml` — same lint + test on pushes to `main`.
- `release.yml` — manually triggered (Actions → Release → Run workflow) to ship to TestFlight or the App Store. See [Build and Release](https://github.com/the-blue-alliance/the-blue-alliance-ios/wiki/Build-and-Release) for the user flow.
- `update_wiki.yml` — mirrors `docs/**` to the wiki on push to `main`.

These instructions describe what's required to reproduce the CI setup in a fork.

## Configuring Secrets

In **Settings → Secrets and variables → Actions**, set the following repository secrets. The "Used by" column refers to the `*.yml` files above.

| Key | Used by | Description |
| --- | --- | --- |
| `TBA_API_KEY` | `push.yml`, `release.yml` | TBA API read key for the production app. Set this on your fork to whatever read key you want CI builds to use. Generate one at [thebluealliance.com/account](https://www.thebluealliance.com/account). |
| `APPLE_KEY_ID` | `release.yml` | Key ID of an [App Store Connect API key](https://appstoreconnect.apple.com/access/api). Required for both TestFlight and App Store lanes. |
| `APPLE_ISSUER_ID` | `release.yml` | Issuer ID for the same App Store Connect API key. |
| `APPLE_KEY_CONTENT` | `release.yml` | The full `.p8` key contents (newlines and all) for the App Store Connect API key. |
| `MATCH_GIT_REPO` | `release.yml` | URL of the [match](https://docs.fastlane.tools/actions/match/) certificates repo. Format: `https://{github_personal_access_token}@github.com/{org_or_user}/{repo}.git`. The PAT only needs read access to the certs repo. |
| `MATCH_GIT_BASIC_AUTHORIZATION` | `release.yml` | base64'd `username:personal_access_token` for cloning the match repo. See [match git storage docs](https://docs.fastlane.tools/actions/match/#git-storage-on-github). |
| `MATCH_PASSWORD` | `release.yml` | Encryption passphrase for the match repo. See the [fastlane CI docs](https://docs.fastlane.tools/best-practices/continuous-integration/) for setup. |
| `GH_TOKEN` | `release.yml` | A [GitHub personal access token](https://github.com/settings/tokens) with `repo` scope, used to create GitHub Releases and read generated release notes from the API. |
| `SLACK_URL` | `release.yml` | An [Incoming Webhook URL](https://api.slack.com/messaging/webhooks) used by the [fastlane slack action](https://docs.fastlane.tools/actions/slack/) to announce releases in `#github-ios` / `#app-releases`. |

`GITHUB_TOKEN` is provided automatically by GitHub Actions and is used by `update_wiki.yml` to push to the wiki repo — no setup needed beyond ensuring **Settings → Actions → General → Workflow permissions** is set to **Read and write**.

The username/password style fastlane secrets (`FASTLANE_USERNAME` / `FASTLANE_PASSWORD`) are no longer used — App Store Connect API key auth replaces them.

## Setting macOS / Xcode Versions

The macOS image is set per-job via `runs-on:` (currently `xcode-27` on every macOS job; `dependency-pins` runs on `ubuntu-latest`).

There is no Xcode version pin. The `xcode-27` image installs exactly one Xcode and already makes it the default, so jobs just use it. Each one records the build with `xcodebuild -version` and keys its DerivedData cache on that, so a refreshed image starts from a cold cache instead of reusing another toolchain's artifacts.

The list of macOS images, installed Xcode versions, and other preinstalled software lives in the [actions/runner-images](https://github.com/actions/runner-images/tree/main/images/macos) repo (formerly `actions/virtual-environments`).

### Bumping the Xcode version

Every macOS job runs on `xcode-27`, GitHub's public preview image, because it is the only image that carries Xcode 27 — `macos-latest` still tops out at 26.6. The app's `.icon` files use Icon Composer features (`refractivity`, `specular-location`) that 26.6's `actool` can't parse, so 26.6 can't build the app at all.

Point releases need no action: GitHub refreshes the image and the jobs follow. The image is on Xcode 27.0 beta 6 today and moves to the 27.0 RC (build `27A266a`) on the next rollout. Until that lands, archives are built with a beta Xcode, which App Store Connect rejects for App Store review and external TestFlight groups; internal TestFlight still works.

Moving to a new *major* Xcode means changing `runs-on:` — to `xcode-28` when that preview appears, or back to `macos-latest` once it carries Xcode 27 or newer, which is the lowest-maintenance home. Before the first release on a new major:

1. Check the [runner image readme](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md) has a simulator runtime that includes the `DEVICE` model from the `Makefile`.
2. Run `make test` locally, then a Release build. Only Release runs the SIL optimizer, and a new toolchain can crash on code that Debug compiles fine (see the `Gymfile` workaround):
   ```sh
   xcodebuild -scheme "The Blue Alliance" -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
   ```

Because nothing is pinned, a toolchain change can arrive unannounced. Every job logs `xcodebuild -version`, so the build that produced an archive is always in the run log.

A newer Xcode also drops older SDKs, so check `IPHONEOS_DEPLOYMENT_TARGET` and each `Package.swift`'s `platforms:` still resolve to an installed runtime.
