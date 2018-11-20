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
### ios setup_secrets
```
fastlane ios setup_secrets
```
Setup Secrets.plist file (used by CI)
### ios setup_url_schemes
```
fastlane ios setup_url_schemes
```
Setup URL schemes in our project
### ios test_unit
```
fastlane ios test_unit
```
Run unit tests
### ios test_ui
```
fastlane ios test_ui
```
Run UI tests
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
### ios release_changelog
```
fastlane ios release_changelog
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
