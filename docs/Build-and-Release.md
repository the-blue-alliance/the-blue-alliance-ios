## Create New Version
Version numbers in App Store Connect must be unique. CI will [create a new patch version](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/c7b4f59880901564f265484028c9a2639f0256a7/fastlane/Fastfile#L103) after shipping a build to the App Store. However, this step may have timed out on CI and the version number was not updated properly, or you may want to use a different version number for new builds. If either of these is the case, make sure to bump version number manually before shipping a new release.

First, decide what type of version the new version should be

|version_type|version before|version after|
|---|---|---|
|major|v2.3.1|v**3.0.0**|
|minor|v2.3.1|v2.**4.0**|
|patch|v2.3.1|v2.3.**2**|

Once you've decided the type of version, we can create a new version via fastlane.

```
$ bundle exec fastlane new_version version_type:{version_type}
```

fastlane will automatically create a new commit for the version bump.

When shipping beta or App Store builds using CI, CI will manage bumping build numbers accordingly. Beta build build numbers will be incremental, starting with 1. App Store build numbers will always be 99.

## Update Release Notes

Before shipping a build, make sure to update the [release notes](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/master/fastlane/metadata/en-US/release_notes.txt) at `fastlane/metadata/en-US/release_notes.txt`. These notes should describe what has changed between the previous version and the new version.

## Updating Metadata

All [metadata](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/fastlane/metadata) (app name, categories, release notes, etc.) is stored in the `fastlane/metadata` folder. App-wide metadata is in the root of the folder, while locale-specific metadata is in sub-folders (ex: `en-US`). To update app metadata, change the corresponding file in `fastlane/metadata` and [submit a new version](#ship-app-store-build) to the App Store. CI will manage setting the updated metadata in the new release version. Metadata can only be updated by releasing a new version of the app.

If you've updated metadata in App Store Connect, you can download it to the repo via Fastlane

```
$ bundle exec fastlane deliver download_metadata
```

NOTE: Some metadata is not included in the repo, such as emails and addresses. Please make sure to review any downloaded information before pushing to GitHub to make sure you're not doxing anyone.

## Updating Screenshots

[Screenshots](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/fastlane/screenshots) are stored in the `fastlane/screenshots` folder. Screenshots are locale-specific, and updated screenshots must be placed in the corresponding locale sub-folder (ex: `en-US`). Screenshots must be named properly for Fastlane to upload them, but there's zero documentation on the naming specifics. For additional information on App Store screenshots, refer to the [App Store Connect Help page on screenshots](https://help.apple.com/app-store-connect/#/dev910472ff2).

If you've uploaded screenshots in App Store Connect, you can download them in to the repo via Fastlane

```
$ bundle exec fastlane deliver download_screenshots
```

## Ship Beta Build
Shipping a beta build is self-serve and can be done by anyone. Add the `[beta]` tag to the beginning of a commit and push to master, or create a pull request.

```
$ git commit -m "[beta] Beta v2.3.1"
$ git push master
```

Make sure to [bump the version number](#create-new-version) before shipping a new beta build. CI will automatically bump the build number, set release notes from commit messages, and distribute the new beta build to the "Beta" group in TestFlight.

## Ship App Store Build
Shipping an App Store release is self-serve and can be done by anyone. Add the `[app_store]` tag to the beginning of a commit and push to master, or create a pull request.

```
$ git commit -m "[app_store] v2.3.1"
$ git push master
```

Make sure to [bump the version number](#create-new-version) and [update release notes](#update-release-notes) before shipping a new release. CI will manage creating a new [GitHub release](https://github.com/the-blue-alliance/the-blue-alliance-ios/releases), uploading the build to App Store Connect, creating a new version and setting release notes/metadata in App Store Connect, submitting the new release for review, and bumping the version number to a new version.

## Configuring Code Signing via Xcode
Is something on CI fails and a beta or release build has to be shipped manually, you'll need to configure code signing locally.

Pull the latest code signing certificates

```
$ bundle exec fastlane match
```

1. Open the workspace file (`the-blue-alliance-ios.xcworkspace`)
2. Click `the-blue-alliance-ios` project in the project navigator
3. On the left sidebar, under `Targets` click `The Blue Alliance`
3. Click the `General` tab along the top bar
4. Under the `Signing (Release)` section, select the provision profile downloaded by `match` (`match AppStore com.the-blue-alliance.tba`)
5. The `Team` and `Signing Certificate` should update according to the selected provisioning profile.

![](https://i.imgur.com/8JAcykh.png)