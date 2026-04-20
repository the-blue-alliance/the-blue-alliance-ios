The Blue Alliance - iOS App
===
An iOS app for accessing information about the FIRST Robotics Competition. This is a native mobile version of [The Blue Alliance](http://www.thebluealliance.com).

![](https://raw.githubusercontent.com/the-blue-alliance/the-blue-alliance-ios/main/screenshots/app-preview.png)

Contributing
===
Want to add features, fix bugs, or just poke around the code? No problem! [Setup instructions](https://github.com/the-blue-alliance/the-blue-alliance-ios/wiki/Setup) (and lots of other documentation) can be found in [the Wiki](https://github.com/the-blue-alliance/the-blue-alliance-ios/wiki).

Code Style
---
Swift code is formatted with Apple's [`swift-format`](https://github.com/swiftlang/swift-format), which ships with Xcode 16+. CI runs `swift-format lint --strict` on every PR; violations block the build.

To fix formatting locally:
- **Whole tree:** `bundle exec fastlane format` (or `./scripts/swift-format-fix.sh`).
- **One file in Xcode:** Editor → Structure → Format File with swift-format. In Xcode Settings → Key Bindings, search "swift-format" and bind it (e.g. ⌃⌥⌘F) for one-keystroke formatting.
- Configuration lives in `.swift-format` at the repo root.

Project Communication
---
 - Keep up to date with the [mailing list](https://groups.google.com/forum/#!forum/thebluealliance-developers).
 - Chat with us on our [Slack team](https://the-blue-alliance.slack.com/). (Request an invite in the mailing list.)

iOS discussion happens in the `#dev-ios` channel in the Slack
