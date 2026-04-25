To develop for The Blue Alliance for iOS, you will need a machine running macOS.

## Install Build Tool Dependencies
The commands below suggest [Homebrew](https://brew.sh/) to install the dependencies.

1. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store.
   - The version pinned in CI is in [`.xcode-version`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.xcode-version) (currently **26.3**). Anything `>=` that should build cleanly.
2. Install the Xcode command line tools.
   - `xcode-select --install`
   - Or, open Xcode → Settings → Locations → Command Line Tools and select your version of Xcode.
3. Install Ruby. The version pinned for the project is in [`.ruby-version`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.ruby-version) (currently **3.2.2**). Pick whichever option fits your setup:
   - **rvm (recommended for project work)** — installs the exact pinned version automatically when you `cd` into the repo:
     ```
     \curl -sSL https://get.rvm.io | bash -s stable
     source ~/.rvm/scripts/rvm
     # from inside the repo:
     rvm install "$(cat .ruby-version)"
     rvm use "$(cat .ruby-version)"
     ```
   - **Homebrew (simpler, but installs system-wide)**:
     ```
     brew install ruby@3.2
     ```
     Make sure `ruby --version` reports `3.2.x` after this — you may need to add the Homebrew Ruby to your `PATH` (`brew info ruby@3.2` prints the snippet).
4. Install [Bundler](https://bundler.io/):
   - `gem install bundler`

## Install Project Dependencies
These should be done after you've cloned the project and navigated to the project directory.

```
$ bundle install
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
The Blue Alliance for iOS stores secrets locally in a `Secrets.plist` file, which is loaded dynamically at runtime as a dictionary to be used in the app. Create a `Secrets.plist` file from the template `mock-Secrets.plist`

```
$ cp mock-Secrets.plist the-blue-alliance-ios/Secrets.plist
```

If linked properly, the `Secrets.plist` file in the Xcode project navigation should go from being red to being black. Edit `Secrets.plist` (either in Xcode or in a text editor) and fill out the secret values. `tba_api_key` should be the TBA API key you generated in the [Setup TBA API](#setup-tba-api) step.

Building in Xcode
---
1. Be sure you have all required build tools, as described in the [Install Build Tool Dependencies](#install-build-tool-dependencies) section.
2. Install project dependencies, as described in the [Install Project Dependencies](#install-project-dependencies) section.
3. Setup your `Secrets.plist` file, as described in the [Setup Secrets](#setup-secrets) section.
4. Open the workspace file (`the-blue-alliance-ios.xcworkspace`).
5. Build and run The Blue Alliance for iOS.

> **Pick a Simulator as the run destination.** In the Xcode toolbar, set the destination to one of the iOS Simulators (e.g. _iPhone 16 Pro_). Building against an attached physical device requires provisioning, a paid Apple Developer account, and a unique bundle identifier — none of which are necessary for day-to-day development. If you _do_ know what you're doing and want to run on hardware, change the bundle identifier to something namespaced to you (e.g. `com.the-blue-alliance.tba.<your-name>`) so it doesn't collide with the production build, and use your own signing team.

Updating Your Environment
---
If you have a local copy of the repo but haven't worked on it in a while, updating to the latest codebase is fairly straightforward

```
$ git pull
$ bundle install
```
