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
### ios setup_ci
```
fastlane ios setup_ci
```
Setup CI
### ios match_ci
```
fastlane ios match_ci
```
Run match on CI
### ios new_version
```
fastlane ios new_version
```
Create a new app version (major, minor, patch, build) by bumping the version number and creating a changelog
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
