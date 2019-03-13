fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios install_deps
```
fastlane ios install_deps
```
Install project dependencies
### ios setup_ci
```
fastlane ios setup_ci
```
Setup CI
### ios test_unit
```
fastlane ios test_unit
```
Run TBA unit tests
### ios test_tbakit
```
fastlane ios test_tbakit
```
Run TBAKit unit tests
### ios test
```
fastlane ios test
```
Run all of our tests
### ios setup_secrets
```
fastlane ios setup_secrets
```
Setup Secrets.plist file (used by CI)
### ios configure_code_signing
```
fastlane ios configure_code_signing
```
Configure code signing
### ios new_version
```
fastlane ios new_version
```
Create a new app version (major, minor, patch, build) by bumping the version number and creating a changelog
### ios ensure_version_bump
```
fastlane ios ensure_version_bump
```
Bump version and push if necessary
### ios beta_ci
```
fastlane ios beta_ci
```
Upload a new beta build to TestFlight (for CI machine)
### ios beta
```
fastlane ios beta
```
Upload a new beta build to TestFlight
### ios app_store
```
fastlane ios app_store
```
Upload a new build to the App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
