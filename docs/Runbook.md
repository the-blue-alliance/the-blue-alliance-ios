## Updating Dependencies

### Swift Package Manager

Swift package versions are managed via Xcode.

**File → Packages → Update to Latest Package Versions**

If a major version is pinned in **Project → Package Dependencies**, bump it there first.

### Ruby Gems

To update all dependencies:

```
$ bundle update
```

To update a single dependency:

```
$ bundle update {gem_name}
```

## Updating OS Versions

To bump the minimum supported iOS version, change the [Xcode deployment target](https://developer.apple.com/documentation/xcode/configuring-the-build-settings-of-a-target) on the project and on every target.

The minimum OS version is generally kept as close to the most recent major iOS release as possible. Supporting old OS versions adds gating overhead and multi-version testing for what is, ultimately, a volunteer-maintained app, so we err on the side of dropping older versions promptly.

## Generate Distribution Certificate

Distribution certificates are valid for one year. The expired certificate must be deleted before generating a new one. You'll need access to the Apple Developer account and the certificates repo to do this.

```
$ git clone git@github.com:ZachOrr/tba-ios-certificates.git
$ cd tba-ios-certificates
$ bundle install
$ bundle exec fastlane match nuke distribution
$ bundle exec fastlane match
$ git pull
```

Run `git pull` at the end so the new certs/keys land on your machine.

Other machines pulling the new certs can do so via match from the iOS repo:

```
$ cd the-blue-alliance-ios
$ bundle exec fastlane match
```

This is only necessary if you intend to ship a build manually from your local machine — under normal operation CI handles signing.

## Generate APNs Authentication Key

We use a long-lived APNs authentication key (which does not expire) instead of APNs certificates (which expire annually). Under normal circumstances this key should not need to be regenerated or reconfigured.

If the APNs key needs to be reconfigured, follow the steps in [Firebase's Configuring APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs) guide.

## Symbolicate Crash Logs

dSYM files for every Release CI run are uploaded as a workflow artifact (see [`release.yml`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/.github/workflows/release.yml)) and retained for 90 days. Firebase Crashlytics also receives dSYMs automatically as part of the build/upload process. The source of truth for everything below is [Firebase's Crashlytics docs](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports); the steps here are an abbreviated cheat sheet.

### Re-fetching dSYMs from App Store Connect

If the workflow artifact has expired (or the build was shipped manually), pull dSYMs for a specific shipped build via fastlane:

```
$ bundle exec fastlane dsyms version:3.2.3 build:2
```

This downloads them into `./dsyms/`. Behind the scenes this is fastlane's `download_dsyms` action — see [Apple's docs](https://developer.apple.com/help/app-store-connect/manage-builds/download-dsym-files) for the manual UI flow if fastlane has trouble.

### Uploading to Firebase manually

If Crashlytics is missing symbols for a build, upload the dSYM bundle with the bundled `upload-symbols` script:

```
$ ./scripts/upload-symbols -gsp the-blue-alliance-ios/GoogleService-Info.plist -p ios {path_to_dsym_or_zip}
```

Both individual `.dSYM` directories and `.dSYM.zip` bundles are accepted.
