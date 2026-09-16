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

The Xcode version comes from [`.xcode-version`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.xcode-version). Each macOS job's `Select Xcode` step reads it, points `DEVELOPER_DIR` at `/Applications/Xcode_<version>.app`, and fails if that isn't on the image, so checkout has to run before that step. The value has to match the image's Xcode app name, not a SemVer range.

The list of macOS images, installed Xcode versions, and other preinstalled software lives in the [actions/runner-images](https://github.com/actions/runner-images/tree/main/images/macos) repo (formerly `actions/virtual-environments`).

### Bumping the Xcode version

Every macOS job runs on `xcode-27`, GitHub's public preview image, because it is the only image that carries Xcode 27 — `macos-latest` still tops out at 26.6. The app's `.icon` files use Icon Composer features (`refractivity`, `specular-location`) that 26.6's `actool` can't parse, so 26.6 can't build the app at all.

The image installs exactly one Xcode and already makes it the default, so nothing needs to select it — `DEVELOPER_DIR` just pins which one we meant. Both the current image (27.0 beta 6) and the next one (27.0 RC, build `27A266a`) publish an `/Applications/Xcode_27.0.app` symlink, so the pin holds across that refresh. Until it lands, archives are built with a beta Xcode, which App Store Connect rejects for App Store review and external TestFlight groups; internal TestFlight still works.

1. Check the [runner image readme](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md) lists the Xcode version, and that its simulator runtime includes the `DEVICE` model from the `Makefile`. The pin has to name an Xcode already on the image.
2. Edit `.xcode-version` and the version quoted in [`Setup.md`](Setup.md). The DerivedData cache keys include the pin, so a bump starts from a cold cache rather than reusing another toolchain's build artifacts.
3. Run `make test` locally, then a Release build. Only Release runs the SIL optimizer, and a new toolchain can crash on code that Debug compiles fine (see the `Gymfile` workaround):
   ```sh
   xcodebuild -scheme "The Blue Alliance" -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
   ```

A newer Xcode also drops older SDKs, so check `IPHONEOS_DEPLOYMENT_TARGET` and each `Package.swift`'s `platforms:` still resolve to an installed runtime.
