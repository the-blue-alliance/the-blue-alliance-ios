The Blue Alliance - iOS App
===

An iOS app for accessing information about the FIRST Robotics Competition.

Setup
===

Build Tool Dependencies
---
The Blue Alliance for iOS has a few build tool dependencies. Here's how to install those, if you need them

1. Install [Xcode](https://developer.apple.com/xcode/)
	* The Blue Alliance for iOS is written in Swift 4.1, which comes with Xcode 9.3+
2. Install [Ruby](https://www.ruby-lang.org/en/) (if it's not already installed on your system) and [Bundler](https://bundler.io/)
	* `gem install bundler`
3. Install gem dependencies with bundler
	* `bundle install`
4. Install [Node/npm](https://nodejs.org/en/)
	* `brew install node`
5. (Optional) Install [React Native](https://facebook.github.io/react-native) - this is only necessary if you're testing local changes to the React Native bundles
	* `brew install watchman`
	* `npm install -g react-native-cli`

Setup Firebase
---
The Blue Alliance's mobile apps depend on Firebase. We configure Firebase in The Blue Alliance for iOS using a `GoogleService-Info.plist` file, provided by Firebase. The production plist isn't checked in to source control, since it contains an API key. You can setup your own Firebase application to develop against.

1. Navigate to the [Firebase Console](https://console.firebase.google.com/u/0/)
2. Click `Add Project`
3. Enter a project name to work with - preferrably something namespaced to yourself (ex: `zach-tba-dev`)
4. After your project is done setting up, click your newly created project
5. On the landing page, click `Add Firebase to your iOS app`
6. Enter a locally namespaced bundle identifier (ex: `com.the-blue-alliance.zach-tba-dev`)
7. Click `Register App`
8. Download the `GoogleService-Info.plist`

Building in Xcode
---
1. Clone The Blue Alliance for iOS
2. Be sure you have all required build tools, as described in the [Build Tool Dependencies](#build-tool-dependencies) section
3. Install [React Native](https://facebook.github.io/react-native) dependencies
	* `cd js && npm install && cd ..`
4. Install [Cocoapods](http://guides.cocoapods.org/using/getting-started.html#getting-started) dependencies
	* `bundle exec pod install --repo-update`
5. Open the workspace file (`the-blue-alliance-ios.xcworkspace`)
6. Modify your bundle identifier to the same bundle identifier you used during your Firebase setup (ex: `com.the-blue-alliance.zach-dev`)
7. Add your `GoogleService-Info.plist` to `the-blue-alliance-ios/the-blue-alliance-ios` folder
	* If you don't have a Firebase project setup, see the [Setup Firebase Project](#setup-firebase) section
	* If linked properly, the `GoogleService-Info.plist` file in the Xcode project navigation should go from being red to being black
8. Build and run The Blue Alliance for iOS!

Contributing
============

Want to add features, fix bugs, or just poke around the code? No problem!

Project Communication
---
 - Keep up to date with the [mailing list](https://groups.google.com/forum/#!forum/thebluealliance-developers).
 - Chat with us on our [Slack team](https://the-blue-alliance.slack.com/). (Request an invite in the mailing list.)

iOS discussion happens in the `#dev-ios` channel in the Slack

Learning
---
Future information on project structure, classes, etc. coming later

Finding Tasks
---
Outstanding work for The Blue Alliance for iOS is tracked in [GitHub Issues](https://github.com/the-blue-alliance/the-blue-alliance-ios/issues). All Issues are [tagged with labels](https://github.com/the-blue-alliance/the-blue-alliance-ios/labels). Issues have a priority (`high priority`, `low priority`, `nice to have`) and a type (`bug`, `enhancement`), as well as some additional information (`feature parity`, `good first issue`, `TBAKit`, etc).

If you're new to The Blue Alliance for iOS, the [`good first issue` label](https://github.com/the-blue-alliance/the-blue-alliance-ios/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) is a great place to start!

Make Commits!
---
1. Fork this repository and follow setup setups
2. Make, commit, and push your changes to your branch
3. Submit a pull request here and we'll review it and get it added in!

For more detailed instructions, see [GitHub's Guide to Contributing](https://guides.github.com/activities/contributing-to-open-source/).

Miscellaneous
===

This is the junk drawer of sections. If you're looking for information not covered above, it might be here. Eventually, this information will move to the Wiki.

Developing React Native Views
---
If you're looking to add to or modify the React Native views (EventStats or MatchBreakdown), you can test your local changes by starting the React Native server

* Start server: `cd js && react-native start`
* To view RN logs: `react-native log-ios`
* Debugging is easier if you install [react-devtools](https://github.com/facebook/react-devtools/tree/master/packages/react-devtools)

Shipping
-----
Be sure to compile a local React Native bundle to be used offline

```
$ cd js
$ react-native bundle --platform ios --dev false --assets-dest ios --entry-file index.ios.js --bundle-output ios/main.jsbundle --reset-cache
```

myTBA Debug Setup
------------------
Debug builds of the TBA app cannot receive (Firebase Cloud Messaging) push notifications from production TBA servers. To test the myTBA features of the app, e.g. to test push notifications end-to-end, you must set up a debug [TBA server](https://github.com/the-blue-alliance/the-blue-alliance) then configure the server and temporarily modify the app code.
