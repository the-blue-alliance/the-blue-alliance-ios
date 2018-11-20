The Blue Alliance - iOS App
===

An iOS app for accessing information about the FIRST Robotics Competition.

Setup
===

Install Build Tool Dependencies
---
The Blue Alliance for iOS has a few build tool dependencies. Here's how to install those, if you need them. The commands below suggest [Homebrew](https://brew.sh/) to install the dependencies. If you're on Windows or Linux, follow the links to find platform-specific setup instructions.

1. Install [Xcode](https://developer.apple.com/xcode/)
	* The Blue Alliance for iOS is written in Swift 4.2, which comes with Xcode 10
2. Install [Ruby](https://www.ruby-lang.org/en/) (if it's not already installed on your system) and [Bundler](https://bundler.io/)
	* `brew install ruby`
	* `gem install bundler`
3. Install [Node/npm](https://nodejs.org/en/)
	* `brew install node`


Install Project Dependencies
---
These should be done after you've cloned the project and navigated to the project directory

1. Install [React Native](https://facebook.github.io/react-native) dependencies
	* `cd subtrees/the-blue-alliance-react && npm install && cd ../..`
2. Install Ruby dependencies
	* `bundle install`
3. Install [Cocoapods](http://guides.cocoapods.org/using/getting-started.html#getting-started) dependencies
	* `bundle exec pod install --repo-update`

Setup Firebase
---
The Blue Alliance's mobile apps depend on Firebase. We configure Firebase in The Blue Alliance for iOS using a `GoogleService-Info.plist` file, provided by Firebase. You can setup your own Firebase application to develop against.

1. Navigate to the [Firebase Console](https://console.firebase.google.com/u/0/)
2. Click `Add Project`
3. Enter a project name to work with - preferrably something namespaced to yourself (ex: `zach-tba-dev`)
4. After your project is done setting up, click your newly created project
5. On the landing page, click `Add Firebase to your iOS app`
6. Enter a locally namespaced bundle identifier (ex: `com.the-blue-alliance.tba.zach-tba-dev`)
7. Click `Register App`
8. Download the `GoogleService-Info.plist`

Setup Realtime Database
---
The Blue Alliance uses Firebase’s [Realtime Database](https://firebase.google.com/docs/database/) feature to sync information about FMS data availability and “down” events in realtime to clients. You may want to simulate this in your app for testing.

1. Navigate to your Firebase project
2. Click `Database`, under `Develop` in the left hand toolbar
3. Create a Realtime Database - NOT a Cloud Firestore
4. For simplicity, when prompted to set security rules for your Realtime Database, select `Start in test mode`
5. Click `Enable`
6. Under the hierarchy in your database, click the `+` button to add key/values

Here’s an example of a configuration a Realtime Database where the FMS data feed is up, and one event (2018mike2) is offline.

![realtime-database-example](screenshots/realtime-database-example.png)

Setup TBA API
---
The Blue Alliance's mobile apps depend on The Blue Alliance's API for providing data. You'll need an API key to develop with when testing/building.

1. Navigate to [The Blue Alliance's Account page](https://www.thebluealliance.com/account) (sign in if prompted)
2. Scroll down to `Read API Keys`
3. Enter a locally namespaced description (ex: `zach-tba-ios-dev`)
4. Click `+ Add New Key` to generate a new API key

We'll use this key in the [Setup Secrets](#setup-secrets) step when setting up local secrets in the The Blue Alliance for iOS project.

Setup Secrets
---
The Blue Alliance for iOS stores secrets locally in a `Secrets.plist` file, which is loaded dynamically at runtime as a dictionary to be used in the app. Create a `Secrets.plist` file from the template `mock-Secrets.plist`

```
$ cp mock-Secrets.plist the-blue-alliance-ios/Secrets.plist
```

If linked properly, the `Secrets.plist` file in the Xcode project navigation should go from being red to being black. Click `Secrets.plist` to edit it, and fill out the secret values. `tba_api_key` should be the TBA API key you generated in the [Setup TBA API](#setup-tba-api) step.

Building in Xcode
---
Before building in Xcode, make sure you've setup a Firebase project, as described in the [Setup Firebase](#setup-firebase) section

1. Be sure you have all required build tools, as described in the [Install Build Tool Dependencies](#install-build-tool-dependencies) section
2. Install project dependencies, as described in the [Install Project Dependencies](#install-project-dependencies) section
3. Open the workspace file (`the-blue-alliance-ios.xcworkspace`)
4. Modify your bundle identifier to the same bundle identifier you used during your Firebase setup
	* Click `the-blue-alliance-ios` project in the left sidebar in Xcode
	* On the left sidebar, under `Targets` click `The Blue Alliance`
	* Click the `General` tab along the top bar
	* Change `Bundle Identifier` to the bundle identifier you set during Firebase setup
5. Replace the existing `GoogleService-Info.plist` is in the `the-blue-alliance-ios/the-blue-alliance-ios` folder.
6. Build and run The Blue Alliance for iOS!

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

Working with React Native
---

Instructions for installing, building, and debugging/running locally the React Native code can be found in [the-blue-alliance-react](https://github.com/the-blue-alliance/the-blue-alliance-react) repo. Execute these commands while in the `subtrees/the-blue-alliance-react` folder

If you make changes to the React Native code and want to push them upstream, you can do this locally from this repo

1. Add your forked project remote
	* `git remote add <REMOTE NAME> <YOUR FORK URL>`
	* Example: `git remote add zach-the-blue-alliance-react https://github.com/ZachOrr/the-blue-alliance-react.git`
2. Push your changes to your forked repo
	* `git subtree push --prefix=subtrees/the-blue-alliance-react <REMOTE NAME> <REMOTE BRANCH>`
	* Example: `git subtree push --prefix=subtrees/the-blue-alliance-react zach-the-blue-alliance-react master`
3. Open a [Pull Request](https://github.com/the-blue-alliance/the-blue-alliance-react/pulls) against [the-blue-alliance-react](https://github.com/the-blue-alliance/the-blue-alliance-react) repo!

myTBA Debug Setup
------------------
Debug builds of the TBA app cannot receive (Firebase Cloud Messaging) push notifications from production TBA servers. To test the myTBA features of the app, e.g. to test push notifications end-to-end, you must set up a debug [TBA server](https://github.com/the-blue-alliance/the-blue-alliance) then configure the server and temporarily modify the app code.
