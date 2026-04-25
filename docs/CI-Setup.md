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

The Xcode version is loaded from the repo's [`.xcode-version`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.xcode-version) file by [`maxim-lobanov/setup-xcode`](https://github.com/maxim-lobanov/setup-xcode). To bump CI's Xcode, edit `.xcode-version`. The lint and test workflows pass `xcode-version-file: .xcode-version`; the release workflow currently pins `latest-stable` (worth aligning if you're picky).

The list of macOS images, installed Xcode versions, and other preinstalled software lives in the [actions/runner-images](https://github.com/actions/runner-images/tree/main/images/macos) repo (formerly `actions/virtual-environments`).
