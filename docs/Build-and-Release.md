## Create New Version
Version numbers in App Store Connect must be unique. CI will [create a new patch version](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/fastlane/Fastfile) after shipping a build to the App Store. However, this step may have timed out on CI and the version number was not updated properly, or you may want to use a different version number for new builds. If either of these is the case, make sure to bump version number manually before shipping a new release.

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

CI manages build numbers for both TestFlight and App Store builds — bumping incrementally based on the latest build in App Store Connect. You don't need to set them manually.

## TestFlight Release Notes

TestFlight (beta) release notes live in [`fastlane/release_notes/beta.md`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/fastlane/release_notes/beta.md). The file is read verbatim by the `beta_ci` lane and shown to TestFlight testers as the "What to Test" notes for the build.

Update `beta.md` in the same PR (or a preceding PR) as the changes you want testers to exercise. A good entry covers:

- **Header line** with the version (e.g. `The Blue Alliance v3.4.0`).
- **What's new** — user-visible changes shipping in this build.
- **Bug fixes** — notable fixes since the last beta.
- **Please poke at** — specific flows you want testers to validate. This is the most important section; without it testers don't know what changed or where to look.
- **Under the hood** (optional) — refactors or infra changes worth flagging to technical testers.

Keep entries terse and scannable — testers read these on a phone. Replace the contents wholesale for each new beta; the file is not append-only.

## App Store Release Notes

Before shipping an App Store build, update the [release notes](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/fastlane/metadata/en-US/release_notes.txt) at `fastlane/metadata/en-US/release_notes.txt`. These notes describe what changed between the previous App Store version and the new one and are shown on the App Store listing.

## Updating Metadata

All [metadata](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/main/fastlane/metadata) (app name, categories, release notes, etc.) is stored in the `fastlane/metadata` folder. App-wide metadata is in the root of the folder, while locale-specific metadata is in sub-folders (ex: `en-US`). To update app metadata, change the corresponding file in `fastlane/metadata` and [submit a new App Store build](#ship-an-app-store-build) — CI will push the updated metadata to App Store Connect alongside the new release. Metadata can only be updated by releasing a new version of the app.

If you've updated metadata in App Store Connect, you can download it to the repo via Fastlane

```
$ bundle exec fastlane deliver download_metadata
```

NOTE: Some metadata is not included in the repo, such as emails and addresses. Please make sure to review any downloaded information before pushing to GitHub to make sure you're not doxing anyone.

## Updating Screenshots

[Screenshots](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/main/fastlane/screenshots) are stored in the `fastlane/screenshots` folder. Screenshots are locale-specific, and updated screenshots must be placed in the corresponding locale sub-folder (ex: `en-US`). Screenshots must be named properly for Fastlane to upload them, but there's zero documentation on the naming specifics. For additional information on App Store screenshots, refer to the [App Store Connect Help page on screenshots](https://help.apple.com/app-store-connect/#/dev910472ff2).

If you've uploaded screenshots in App Store Connect, you can download them in to the repo via Fastlane

```
$ bundle exec fastlane deliver download_screenshots
```

## Ship a TestFlight Build

TestFlight builds are shipped manually from the GitHub Actions UI:

1. Make sure `main` is at the commit you want to ship and that [`beta.md`](#testflight-release-notes) reflects this build.
2. Go to **Actions → Release → Run workflow** on GitHub.
3. Select branch `main`.
4. For **What to build**, choose `TestFlight`.
5. For **Retype the selection to confirm**, type `TestFlight` exactly.
6. Click **Run workflow**.

CI will bump the build number, run the `beta_ci` fastlane lane, and distribute the build to the "Beta" group in TestFlight using the contents of `beta.md` as the test notes.

If you need to bump the version (vs. just shipping another beta of the current version), do that first via [`fastlane new_version`](#create-new-version) and merge the bump to `main` before kicking off the workflow.

## Ship an App Store Build

App Store builds are shipped manually from the GitHub Actions UI:

1. Make sure `main` is at the commit you want to ship and that [`fastlane/metadata/en-US/release_notes.txt`](#app-store-release-notes) reflects this release.
2. Go to **Actions → Release → Run workflow** on GitHub.
3. Select branch `main`.
4. For **What to build**, choose `App Store`.
5. For **Retype the selection to confirm**, type `App Store` exactly (the workflow refuses to run if this doesn't match).
6. Click **Run workflow**.

CI will bump the build number, run the `app_store` fastlane lane, create a new [GitHub release](https://github.com/the-blue-alliance/the-blue-alliance-ios/releases), upload the build to App Store Connect, push updated metadata, submit the new release for review, and bump the patch version for the next cycle.

The confirmation field exists because App Store submissions are public and hard to undo — re-typing the lane is a deliberate guard against accidentally selecting the wrong option in the dropdown.

## Configuring Code Signing via Xcode
If something on CI fails and a beta or release build has to be shipped manually, you'll need to configure code signing locally.

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
