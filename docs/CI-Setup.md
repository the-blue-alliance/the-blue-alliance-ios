The Blue Alliance for iOS leverages GitHub Actions for CI, shipping TestFlight builds, shipping App Store builds, updating dSYMs in Firebase Crashlytics, and more. These instructions outline how to reproduce the CI/CD setup for The Blue Alliance for iOS. Also see the [fastlane Setup documentation](https://zachorr.com) for details on configuring fastlane (match, etc).

## Configuring Secrets

In the `Settings/Secrets` tab, set the following secrets -

| Key | Description |
| --- | --- |
| `FASTLANE_USERNAME` | Follow the steps in the fastlane [Continuous Integration](https://docs.fastlane.tools/best-practices/continuous-integration/) documentation for details on setting this secret. |
| `FASTLANE_PASSWORD` | Follow the steps in the fastlane [Continuous Integration](https://docs.fastlane.tools/best-practices/continuous-integration/) documentation for details on setting this secret. |
| `MATCH_GIT_REPO` | The git repo where the match keys are kept. In our case, this format should be `https://{github_personal_access_token}@github.com/{org/user}/{repo}.git`. The easiest way to authenticate the git url for cloning is by using a [GitHub personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token). |
| `MATCH_PASSWORD` | Follow the steps in the fastlane [Continuous Integration](https://docs.fastlane.tools/best-practices/continuous-integration/) documentation for details on setting this secret. |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Follow the steps in the fastlane [match](https://docs.fastlane.tools/actions/match/#git-storage-on-github) documentation for details on setting this secret. |
| `GH_TOKEN` | A [GitHub personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) to enable uploading releases for `the-blue-alliance/the-blue-alliance-ios` repo. |
| `TBA_API_KEY` | The TBA API key to use for production (TestFlight and App Store) builds. |
| `SLACK_URL` | Used for the [fastlane slack Action](https://docs.fastlane.tools/actions/slack/) - the `Webhook URL` for the [Incoming Webhook](https://slack.com/apps/A0F7XDUAZ-incoming-webhooks) integration. Follow the ["Sending messages using Incoming Webhooks"](https://api.slack.com/messaging/webhooks) for details on setting up this integration. |

## Setting macOS/Xcode Versions

To set a macOS version for the GitHub Actions, change the `runs-on` directive for a job. At the time of writing, all GitHub Actions run using the `macos-latest` option.

To set an Xcode version for the GitHub Actions, change the `xcode-version` directive for the `setup-xcode` for a job. At the time of writing, all GitHub Actions run using the `latest-stable` option. However, this value should match the Xcode version specified in the [Setup guide](https://github.com/the-blue-alliance/the-blue-alliance-ios/wiki/Setup).

See the list of supported macOS, Xcode, and other software versions can be found in the [GitHub Actions macOS virtual environment README](https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md). If the README is broken, find the new README in the [`images/macos` folder](https://github.com/actions/virtual-environments/blob/main/images/macos/).