# react-native-tba-callback-manager

## Getting started

`$ npm install react-native-tba-callback-manager --save`

### Mostly automatic installation

`$ react-native link react-native-tba-callback-manager`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tba-callback-manager` and add `TBACallbackManager.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libTBACallbackManager.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.reactlibrary.TBACallbackManagerPackage;` to the imports at the top of the file
  - Add `new TBACallbackManagerPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-tba-callback-manager'
  	project(':react-native-tba-callback-manager').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tba-callback-manager/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-tba-callback-manager')
  	```


## Usage
```javascript
import TBACallbackManager from 'react-native-tba-callback-manager';

// TODO: What to do with the module?
TBACallbackManager;
```
