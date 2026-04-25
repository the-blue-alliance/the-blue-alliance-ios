## Updating Dependencies

### SPM

Updating a dependency via SPM should be handled via Xcode.

File -> Swift Packages -> Update to Latest Package Versions

The version numbers might need to be bumped in Project -> Package Dependencies

### Ruby Gems

To update all dependencies

```
$ bundle update
```

To update a single dependency

```
$ bundle update {gem_name}
```

## Updating OS Versions

In order to update the required OS version, change the [Xcode deployment target](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/WorkingwithTargets.html) for the project and all targets in Xcode, the [`Podfile` `platform :ios`](https://guides.cocoapods.org/syntax/podfile.html#platform) version, and all of the [`*.podspec` `ios.deployment_target`](https://guides.cocoapods.org/syntax/podspec.html#deployment_target) versions. These versions should all match.

The required OS version is generally kept as close to the most recent major release as possible. Supporting old OS versions comes with overhead around gating newer-OS-specific code, testing across multiple versions, etc. In order to keep the overhead of working on and maintaining this open source project as low as possible, The Blue Alliance for iOS generally only supports most recent major OS version.

### Xcode

![](https://i.imgur.com/VuMuLat.png)
![](https://i.imgur.com/LeLydZb.png)

## Generate Distribution Certificate
Distribution certificates are only valid for a year at a time and must be re-generated. You must delete the old, expired certificate before generating a new certificate. Note: You must have access to the Apple Developer account and the certificates repo in order to generate new certs.

```
$ git clone git@github.com:ZachOrr/tba-ios-certificates.git
$ cd tba-ios-certificates
$ bundle install
$ bundle exec fastlane match nuke distribution
$ bundle exec fastlane match
$ git pull
```

Make sure to do a `git pull` at the end to get the certs and keys on your machine.

Machines or users looking to pull new distribution certs can do so via match from TBA for iOS. This is only necessary if you're going to ship an update to the App Store from your local machine, which isn't advised. CI handles this for us automatically.

```
$ cd the-blue-alliance-ios
$ bundle exec fastlane match
```

## Generate APNs Authentication Key
We do not use APNs certificates, as they are only valid for a year at a time and need to be regenerated. Instead we use a long-lived APNs authentication key which does not expire. Under normal circumstances, this key should not have to be regenerated or reconfigured.

If an APNs key needs to be reconfigured, follow the steps in [Firebase's Configuring APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs) guide.

## Symbolicate Crash Logs

All dSYM files are automatically downloaded from App Store Connect and uploaded to Firebase daily [via CI](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/c7b4f59880901564f265484028c9a2639f0256a7/.travis.yml#L36). However, if something goes wrong, symbol files can be uploaded to Firebase manually. The source of truth for this is [Firebase's documentation](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports), but this attempts to provide abbreviated steps.

### Find dSYM Bundle

Download the dSYM symbols [via App Store Connect](https://docs.fabric.io/apple/crashlytics/missing-dsyms.html#downloading-bitcode-dsyms) by going to `Apps` -> `The Blue Alliance` -> `Activity` -> `Select the version/build number` -> `Click Download dSYM`.

### Upload dSYM Bundle

You can upload dSYM files by going to the Firebase project, clicking the `Crashlytics` tab in the sidebar, selecting `The Blue Alliance for iOS` project, clicking the `dSYMs` tab, and uploading dSYM zip files.

![](https://zachorr.com/tba/firebase-dsym.png)

The web interface can be buggy sometimes and fail. Uploading via the command line is a more reliable way of uploading dSYM files. The details of this will be better kept up-to-date [by Firebase](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports), but for now, here's what you run in the project's root

```
$ Pods/FirebaseCrashlytics/upload-symbols -gsp the-blue-alliance-ios/GoogleService-Info.plist -p ios {path_to_dsym.zip}
```