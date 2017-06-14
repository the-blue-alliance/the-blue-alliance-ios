The Blue Alliance - iOS App
=====================

An iOS app for accessing information about the FIRST Robotics Competition.

Setup
-----
0. Install all [React Native](https://facebook.github.io/react-native) dependencies
	* `brew install node watchman`
	* `npm install -g react-native-cli`
	* `npm install`
1. Install [Cocoapods](http://guides.cocoapods.org/using/getting-started.html#getting-started) to install package dependencies
	* `sudo gem install cocoapods`
	* `pod install`
	* Open the project (`the-blue-alliance-ios.xcworkspace`)
2. Run the React Native server
	* `cd js && react-native start`
	* To view RN logs, `react-native log-ios`
3. Build and run The Blue Alliance for iOS in Xcode!

Shipping
-----
0. Be sure to compile a local React Native bundle to be used offline

```
$ cd js
$ react-native bundle --platform ios --dev false --entry-file index.ios.js --bundle-output ../the-blue-alliance-ios/React\ Native/main.jsbundle --assets-dest ../the-blue-alliance-ios/React\ Native/
```
