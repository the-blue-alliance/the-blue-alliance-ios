To develop for The Blue Alliance for iOS, you will need a machine running macOS.

## Install Build Tool Dependencies
Xcode is the only prerequisite.

1. Install [Xcode 27](https://developer.apple.com/xcode/) from the Mac App Store. The app builds against the iOS 27 SDK and runs on iOS 26 and later.
   - CI uses whatever Xcode 27 its runner image ships, so there's no version to keep in sync.
2. Install the Xcode command line tools.
   - `xcode-select --install`
   - Or, open Xcode → Settings → Locations → Command Line Tools and select your version of Xcode.

There are no other dependencies to install — Xcode resolves Swift packages on first build.

## Common Commands
Everything you'll run day to day is a `make` target, and CI runs these same targets.

```
$ make help          # list every target
$ make test          # all tests
$ make format        # format with swift-format
$ make lint          # what CI checks
```

Setup TBA API
---
The Blue Alliance's mobile apps depend on The Blue Alliance's API for providing data. You'll need an API key to develop with when testing/building.

1. Navigate to [The Blue Alliance's Account page](https://www.thebluealliance.com/account) (sign in if prompted)
2. Scroll down to `Read API Keys`
3. Enter a locally namespaced description (ex: `zach-tba-ios-dev`)
4. Click `+ Add New Key` to generate a new API key

We'll use this key in the [Setup Secrets](#setup-secrets) step when setting up local secrets in the The Blue Alliance for iOS project.

Setup Secrets
---
The Blue Alliance for iOS stores secrets locally in a `Secrets.plist` file, which is loaded dynamically at runtime as a dictionary to be used in the app. `make secrets` creates the file if it's missing, and fills in `tba_api_key` from the `TBA_API_KEY` environment variable when one is set.

```
$ TBA_API_KEY=<your key> make secrets
```

Running it without `TBA_API_KEY` still creates an empty `Secrets.plist`, which is all the offline tests need.

If linked properly, the `Secrets.plist` file in the Xcode project navigation should go from being red to being black. Edit `Secrets.plist` (either in Xcode or in a text editor) and fill out the secret values. `tba_api_key` should be the TBA API key you generated in the [Setup TBA API](#setup-tba-api) step.

Building in Xcode
---
1. Be sure you have all required build tools, as described in the [Install Build Tool Dependencies](#install-build-tool-dependencies) section.
2. Setup your `Secrets.plist` file, as described in the [Setup Secrets](#setup-secrets) section.
3. Open the project file (`the-blue-alliance-ios.xcodeproj`).
4. Build and run The Blue Alliance for iOS.

> **Pick a Simulator as the run destination.** In the Xcode toolbar, set the destination to one of the iOS Simulators (e.g. _iPhone 17 Pro_). Building against an attached physical device requires provisioning, a paid Apple Developer account, and a unique bundle identifier — none of which are necessary for day-to-day development. If you _do_ know what you're doing and want to run on hardware, change the bundle identifier to something namespaced to you (e.g. `com.the-blue-alliance.tba.<your-name>`) so it doesn't collide with the production build, and use your own signing team.

Updating Your Environment
---
If you have a local copy of the repo but haven't worked on it in a while, updating to the latest codebase is fairly straightforward

```
$ git pull
```
