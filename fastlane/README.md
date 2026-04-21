fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios install_deps

```sh
[bundle exec] fastlane ios install_deps
```

Install project dependencies

### ios test_mytbakit

```sh
[bundle exec] fastlane ios test_mytbakit
```

Run MyTBAKit unit tests

### ios test

```sh
[bundle exec] fastlane ios test
```

Run all of our tests

### ios format

```sh
[bundle exec] fastlane ios format
```

Format all Swift files with swift-format

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint Swift formatting (strict, used by CI)

### ios setup_secrets

```sh
[bundle exec] fastlane ios setup_secrets
```

Setup Secrets.plist file (used by CI)

### ios dsyms

```sh
[bundle exec] fastlane ios dsyms
```

Download dSYMs for a specific build. Usage: fastlane dsyms version:3.2.3 build:2

### ios beta_ci

```sh
[bundle exec] fastlane ios beta_ci
```

Upload a new beta build to TestFlight (for CI machine)

### ios app_store

```sh
[bundle exec] fastlane ios app_store
```

Upload a new build to the App Store

### ios new_version

```sh
[bundle exec] fastlane ios new_version
```

Create a new app version (major, minor, patch) by bumping the version number

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
