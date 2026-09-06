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

The macOS image is set per-job via `runs-on:` (currently `macos-latest` on every job).

[`.xcode-version`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.xcode-version) is the **single source of truth** for the Xcode version. Every job in `ci.yml` and `release.yml` reads it into a step output and hands it to [`maxim-lobanov/setup-xcode`](https://github.com/maxim-lobanov/setup-xcode); nothing pins a version inline. Note that each of those jobs has to check out the repo *before* the setup-xcode step, since it reads a file from the repo.

The list of macOS images, installed Xcode versions, and other preinstalled software lives in the [actions/runner-images](https://github.com/actions/runner-images/tree/main/images/macos) repo (formerly `actions/virtual-environments`).

### Bumping the Xcode version

1. **Check the target Xcode is on the runner image.** Open the readme for the image `runs-on:` resolves to — `macos-latest` is currently macOS 26, so [`macos-26-arm64-Readme.md`](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md) — and confirm the version is listed. `setup-xcode` can only select an Xcode already installed on the image; it cannot download one.
2. **Check the simulator runtime you need ships with it.** The readme lists installed simulator runtimes *per Xcode version*, and they differ a lot. Xcode 26.3, for example, ships only iOS 26.2, while 26.5 and 26.6 ship iOS 26.2/26.4/26.5. The test lanes deliberately name a device (`TEST_DEVICES` in the `Fastfile`) without a runtime version so they resolve against whatever the pinned Xcode provides — don't add a runtime version unless you've confirmed it's on the image.
3. **Confirm the device model exists.** The same readme lists the simulator device types. `TEST_DEVICES` has to name one of them.
4. **Edit `.xcode-version`** — that one file covers every CI job and the release workflow.
5. **Update the version quoted in [`Setup.md`](Setup.md)**, which tells contributors the minimum local Xcode.
6. **Build and test locally on the new version** before merging (`bundle exec fastlane test`). CI and release will now both be on it, so a regression takes out shipping too.
7. **Also build a Release configuration locally.** CI only compiles Debug, and Release runs the SIL optimizer, which a new Swift toolchain can crash on code that Debug compiles fine (this has happened twice; see the `-sil-disable-pass` workaround in the `Gymfile`). `xcodebuild -scheme "The Blue Alliance" -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` catches that before the App Store lane does.

Bumping is also the moment to sanity-check `IPHONEOS_DEPLOYMENT_TARGET` and each `Package.swift`'s `platforms:` — a newer Xcode drops older SDKs, and a package whose minimum is above every installed simulator runtime will fail destination resolution with an empty destination list rather than an obvious error.
